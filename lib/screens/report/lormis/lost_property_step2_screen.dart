import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:police/services/report_service.dart';
import 'package:police/screens/report/lormis/lost_property_step3_screen.dart';
import 'package:police/helpers/report_step_manager.dart';

/// pubspec.yaml:
///   flutter_map: ^6.1.0
///   latlong2: ^0.9.0
///   geolocator: ^11.0.0
///   file_picker: ^8.0.0
///   http: ^1.2.0
///   flutter_secure_storage: ^9.0.0

class LostPropertyStep2Screen extends StatefulWidget {
  final int reportId;
  const LostPropertyStep2Screen({super.key, required this.reportId});

  @override
  State<LostPropertyStep2Screen> createState() =>
      _LostPropertyStep2ScreenState();
}

class _LostPropertyStep2ScreenState extends State<LostPropertyStep2Screen> {

  // ── date_lost ─────────────────────────────────────────────────────────────
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;

  // ── time_lost ─────────────────────────────────────────────────────────────
  TimeOfDay? _selectedTime;

  // ── location (map) ────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  LatLng _pinLocation = const LatLng(-6.1722, 35.7395);
  bool _pinPlaced = false;
  bool _locationLoading = false;
  bool _geocodingLoading = false;
  String _placeName = 'Tap the map to pin a location';

  // ── landmark & circumstances ──────────────────────────────────────────────
  final TextEditingController _landmarkCtrl = TextEditingController();
  final TextEditingController _circumstancesCtrl = TextEditingController();

  // ── file upload ───────────────────────────────────────────────────────────
  String? _selectedFileName;
  File? _selectedFileObj;

  // ── saving ────────────────────────────────────────────────────────────────
  bool _isSaving = false;

  @override
  void dispose() {
    _landmarkCtrl.dispose();
    _circumstancesCtrl.dispose();
    super.dispose();
  }

  // ── Reverse geocoding ─────────────────────────────────────────────────────
  Future<String> _getPlaceName(double lat, double lng) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse'
            '?lat=$lat&lon=$lng&format=json&zoom=14&addressdetails=1'),
        headers: {'User-Agent': 'LostPropertyApp/1.0', 'Accept-Language': 'en'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final addr = (body['address'] as Map<String, dynamic>?) ?? {};
        final part1 = addr['neighbourhood'] ??
            addr['suburb'] ??
            addr['quarter'] ??
            addr['village'] ??
            addr['hamlet'] ??
            addr['road'];
        final part2 = addr['town'] ??
            addr['city'] ??
            addr['municipality'] ??
            addr['county'];
        final part3 = addr['country'];
        final parts = [part1, part2, part3]
            .where((p) => p != null && p.toString().trim().isNotEmpty)
            .map((p) => p.toString().trim())
            .toList();
        if (parts.isNotEmpty) return parts.take(3).join(', ');
        final display = body['display_name'] as String?;
        if (display != null && display.isNotEmpty) {
          return display
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .take(3)
              .join(', ');
        }
      }
    } catch (_) {}

    try {
      final res = await http.get(Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=$lat&longitude=$lng&localityLanguage=en',
      )).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final parts = <String>[];
        for (final key in [
          'locality',
          'city',
          'principalSubdivision',
          'countryName'
        ]) {
          final v = body[key] as String?;
          if (v != null && v.trim().isNotEmpty) parts.add(v.trim());
        }
        if (parts.isNotEmpty) return parts.take(3).join(', ');
      }
    } catch (_) {}

    return 'Unknown location';
  }

  Future<void> _updatePin(LatLng latlng) async {
    setState(() {
      _pinLocation = latlng;
      _pinPlaced = true;
      _geocodingLoading = true;
      _placeName = 'Looking up location...';
    });
    final name = await _getPlaceName(latlng.latitude, latlng.longitude);
    if (mounted) {
      setState(() {
        _placeName = name;
        _geocodingLoading = false;
      });
    }
  }

  void _onMapTap(TapPosition _, LatLng latlng) => _updatePin(latlng);

  Future<void> _useMyLocation() async {
    setState(() => _locationLoading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Location permission denied.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final latlng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latlng, 15);
      await _updatePin(latlng);
    } catch (_) {
      _snack('Could not get location. Please enable GPS.');
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  // ── Time picker ───────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.indigo),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── File picker ───────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileObj = File(result.files.single.path!);
      });
    }
  }

  // ── SAVE TO DATABASE ──────────────────────────────────────────────────────
  Future<void> _saveToDatabase() async {
    setState(() => _isSaving = true);

    try {
      final result = await ReportService.submitLostPropertyStep2(
        reportId: widget.reportId,
        location: _placeName,
        landmark: _landmarkCtrl.text.trim(),
        circumstances: _circumstancesCtrl.text.trim(),
        dateLost: _selectedDate,
        timeLost: _selectedTime,
      );

      if (result['success']) {
         await ReportStepManager.saveStep(3, widget.reportId);

        _snack(result['message'] ?? 'Saved successfully!');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  LostPropertyStep3Screen(reportId: widget.reportId),
            ),
          );
        }
      } else {
        _snack(result['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Validate then save ────────────────────────────────────────────────────
  void _onNext() {
    if (_selectedDate == null) {
      _snack('Please select the date it was lost.');
      return;
    }
    if (!_pinPlaced) {
      _snack('Please select a location on the map.');
      return;
    }
    _saveToDatabase();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Calendar helpers ──────────────────────────────────────────────────────
  int get _daysInMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
  int get _firstWeekdayOffset =>
      DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
  void _previousMonth() => setState(() =>
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  void _nextMonth() => setState(() =>
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1));
  bool _isSelected(int day) =>
      _selectedDate != null &&
      _selectedDate!.year == _focusedMonth.year &&
      _selectedDate!.month == _focusedMonth.month &&
      _selectedDate!.day == day;
  bool _isToday(int day) {
    final n = DateTime.now();
    return n.year == _focusedMonth.year &&
        n.month == _focusedMonth.month &&
        n.day == day;
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String get _monthLabel =>
      '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text('Report Lost Item',
            style: TextStyle(color: Colors.black, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── STEP INDICATOR ────────────────────────────────────────
            _buildStepIndicator(),
            const SizedBox(height: 20),

            // ── WHEN ──────────────────────────────────────────────────
            _label('When was it lost?'),
            const SizedBox(height: 10),
            _buildCalendar(),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  const Icon(Icons.event, color: Colors.indigo, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_monthNames[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}',
                    style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ),

            const SizedBox(height: 24),

            // ── TIME ──────────────────────────────────────────────────
            _label('What time was it lost?'),
            const Text('Optional',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time,
                      color: Colors.indigo, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Tap to select time',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedTime != null
                          ? Colors.black87
                          : Colors.grey,
                      fontWeight: _selectedTime != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedTime != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTime = null),
                      child: const Icon(Icons.clear,
                          size: 16, color: Colors.grey),
                    ),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // ── WHERE ─────────────────────────────────────────────────
            _label('Where was it lost?'),
            const SizedBox(height: 10),
            _buildLocationSection(),

            const SizedBox(height: 24),

            // ── LANDMARK ──────────────────────────────────────────────
            _label('Nearest Landmark'),
            const Text('e.g. Next to KFC, Near Posta building',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _landmarkCtrl,
              hint: 'Enter nearest landmark...',
              icon: Icons.location_city_rounded,
            ),

            const SizedBox(height: 24),

            // ── CIRCUMSTANCES ─────────────────────────────────────────
            _label('Circumstances'),
            const Text('Describe how the item was lost',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _circumstancesCtrl,
              hint: 'Describe what happened...',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // ── FILE ──────────────────────────────────────────────────
            _label('Photos & Documents'),
            const Text('Optional — upload a photo or document',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            _buildFileUpload(),

            const SizedBox(height: 30),

            // ── SAVE BUTTON ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.indigo.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white)),
                          SizedBox(width: 10),
                          Text('Saving...',
                              style: TextStyle(fontSize: 15)),
                        ],
                      )
                    : const Text('Save & Continue →',
                        style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'My Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Step 2 of 3: Location & Details',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E))),
              Text('67% Complete',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.67,
              minHeight: 4,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location section ──────────────────────────────────────────────────────
  Widget _buildLocationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(children: [
              const Icon(Icons.location_on,
                  color: Colors.indigo, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: _geocodingLoading
                    ? const Row(children: [
                        SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.indigo)),
                        SizedBox(width: 8),
                        Text('Looking up location...',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ])
                    : Text(_placeName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _pinPlaced
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _pinPlaced
                              ? Colors.black87
                              : Colors.grey,
                        )),
              ),
            ]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed:
                  (_locationLoading || _geocodingLoading)
                      ? null
                      : _useMyLocation,
              icon: _locationLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.indigo))
                  : const Icon(Icons.my_location_rounded, size: 16),
              label: Text(
                  _locationLoading
                      ? 'Getting GPS...'
                      : 'Use My Location',
                  style: const TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),

        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: SizedBox(
            height: 220,
            child: Stack(children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pinLocation,
                  initialZoom: 13,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.lostproperty',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: _pinLocation,
                      width: 50,
                      height: 60,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red,
                          size: 46,
                          shadows: [
                            Shadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ]),
                    ),
                  ]),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: const Text(
                      '📍 Tap the map to pin where the item was lost',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Generic text field ────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Padding(
            padding:
                EdgeInsets.only(bottom: maxLines > 1 ? 56 : 0),
            child: Icon(icon, color: Colors.indigo, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // ── File upload ───────────────────────────────────────────────────────────
  Widget _buildFileUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(children: [
        Icon(Icons.cloud_upload_outlined,
            size: 44,
            color: _selectedFileName != null
                ? Colors.indigo
                : Colors.grey),
        const SizedBox(height: 8),
        Text(
            _selectedFileName != null
                ? 'File selected'
                : 'Click to upload',
            style: TextStyle(
                color: _selectedFileName != null
                    ? Colors.indigo
                    : Colors.grey,
                fontSize: 13)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file, size: 16),
          label: Text(_selectedFileName != null
              ? 'Change File'
              : 'Select File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        if (_selectedFileName != null)
          Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insert_drive_file,
                    size: 15, color: Colors.indigo),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(_selectedFileName!,
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ]),
    );
  }

  // ── Calendar ──────────────────────────────────────────────────────────────
  Widget _buildCalendar() {
    const dayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final totalCells = _firstWeekdayOffset + _daysInMonth;
    final gridCount = (totalCells / 7).ceil() * 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
            Text(_monthLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey))),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridCount,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 4),
          itemBuilder: (context, index) {
            final day = index - _firstWeekdayOffset + 1;
            if (day < 1 || day > _daysInMonth) {
              return const SizedBox.shrink();
            }
            final sel = _isSelected(day);
            final tod = _isToday(day);
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day)),
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.indigo
                        : tod
                            ? Colors.indigo.withOpacity(0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: tod && !sel
                        ? Border.all(
                            color: Colors.indigo, width: 1.2)
                        : null,
                  ),
                  child: Text('$day',
                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : tod
                                ? Colors.indigo
                                : Colors.black87,
                        fontWeight: sel || tod
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontSize: 13,
                      )),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 15));
}