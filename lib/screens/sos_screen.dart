import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart'; // ← ONGEZA: device_info_plus: ^10.1.0

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  double? _latitude;
  double? _longitude;
  bool _locationLoading = true;
  double _slideValue = 0.0;
  final MapController _mapController = MapController();

  // ── TIMESTAMP VARIABLES ──
  DateTime? _locationCapturedAt;
  DateTime? _sosSentAt;

  // ── DEVICE ID VARIABLES ──
  String? _deviceId;
  String? _deviceModel;
  String? _deviceOS;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _getDeviceInfo(); // ← PATA DEVICE INFO MARA MOJA
  }

  // ── PATA DEVICE ID ──
  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceId = androidInfo.id;                                    // Unique Device ID
          _deviceModel = '${androidInfo.brand} ${androidInfo.model}';   // e.g. Samsung Galaxy A54
          _deviceOS = 'Android ${androidInfo.version.release}';         // e.g. Android 13
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceId = iosInfo.identifierForVendor;                             // Unique Device ID
          _deviceModel = iosInfo.utsname.machine;                              // e.g. iPhone14,2
          _deviceOS = '${iosInfo.systemName} ${iosInfo.systemVersion}';        // e.g. iOS 17.0
        });
      }
    } catch (e) {
      setState(() => _deviceId = 'Unknown');
    }
  }

  // ── FORMAT TIMESTAMP ──
  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return 'Haijulikani';
    return DateFormat('dd MMM yyyy • HH:mm:ss').format(dt);
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationLoading = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoading = false;
        _locationCapturedAt = DateTime.now();
      });
    } catch (e) {
      setState(() => _locationLoading = false);
    }
  }

  void _onSlideComplete() {
    setState(() => _sosSentAt = DateTime.now());

    // ── DATA KAMILI YA TUKIO ──
    final incidentData = {
      'device_id': _deviceId,           // ← Device ID
      'device_model': _deviceModel,     // ← Model ya simu
      'device_os': _deviceOS,           // ← OS version
      'latitude': _latitude,
      'longitude': _longitude,
      'location_captured_at': _locationCapturedAt?.toIso8601String(),
      'sos_sent_at': _sosSentAt?.toIso8601String(),
    };

    // TODO: Tuma incidentData kwenye server yako
    debugPrint('📍 Incident Data: $incidentData');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('SOS Sent!',
                style: TextStyle(
                    color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Your emergency alert has been sent to the authorities with your location.'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // ── DEVICE INFO ──
            _infoRow(Icons.phone_android, 'Device', _deviceModel ?? 'Unknown'),
            const SizedBox(height: 6),
            _infoRow(Icons.perm_device_info, 'Device ID',
                _deviceId != null
                    ? '${_deviceId!.substring(0, 8)}...'
                    : 'Unknown'),
            const SizedBox(height: 6),
            _infoRow(Icons.system_update, 'OS', _deviceOS ?? 'Unknown'),

            const Divider(height: 16),

            // ── LOCATION + TIME ──
            _infoRow(Icons.location_on, 'Eneo',
                '${_latitude?.toStringAsFixed(6)}, ${_longitude?.toStringAsFixed(6)}'),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, 'GPS Ilipatikana',
                _formatTimestamp(_locationCapturedAt)),
            const SizedBox(height: 6),
            _infoRow(Icons.send, 'SOS Ilitumwa',
                _formatTimestamp(_sosSentAt)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E)),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1A237E)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── Stay Connected Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: const Color(0xFF1A237E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stay Connected',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                    'Get the latest alerts and safety updates directly from the force.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A237E),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Sign in to start your session',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Visitor Create Account',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close,
                                size: 22, color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Emergency SOS Alert',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    // ── Warning Text ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "You're about to send an emergency report to the authorities. Use this only if someone's safety or life is in immediate danger.",
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                            height: 1.5),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Map ──
                    SizedBox(
                      height: 220,
                      child: _locationLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF1A237E)),
                            )
                          : _latitude != null
                              ? FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter:
                                        LatLng(_latitude!, _longitude!),
                                    initialZoom: 15,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.police.app',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point:
                                              LatLng(_latitude!, _longitude!),
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_pin,
                                            color: Color(0xFFE53935),
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_off,
                                            color: Colors.grey, size: 36),
                                        SizedBox(height: 8),
                                        Text('Unable to load location',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                    ),

                    // ── Coordinates + Timestamp + Device ID ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // GPS Coordinates
                          Text(
                            _latitude != null && _longitude != null
                                ? 'Latitude: ${_latitude!.toStringAsFixed(6)} • Longitude: ${_longitude!.toStringAsFixed(6)}'
                                : 'Fetching location...',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF555555)),
                          ),
                          const SizedBox(height: 4),

                          // Timestamp
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 13, color: Color(0xFF1A237E)),
                              const SizedBox(width: 4),
                              Text(
                                _locationCapturedAt != null
                                    ? 'Wakati: ${_formatTimestamp(_locationCapturedAt)}'
                                    : 'Inapata wakati...',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // ── DEVICE ID ──
                          Row(
                            children: [
                              const Icon(Icons.phone_android,
                                  size: 13, color: Color(0xFF388E3C)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _deviceId != null
                                      ? 'Device: ${_deviceModel ?? ''} • ID: ${_deviceId!.length > 10 ? '${_deviceId!.substring(0, 10)}...' : _deviceId!}'
                                      : 'Inapata device info...',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF388E3C),
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Emergency Alert Row ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('SOS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Emergency Alert',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE53935)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Slide to Submit ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: const Color(0xFFFFCDD2)),
                            ),
                          ),
                          const Text(
                            'Slide to Submit your Request',
                            style: TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                          Positioned(
                            left: 4,
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: const Color(0xFFE53935),
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 24),
                                trackHeight: 0,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Slider(
                                  value: _slideValue,
                                  min: 0,
                                  max: 1,
                                  onChanged: (val) =>
                                      setState(() => _slideValue = val),
                                  onChangeEnd: (val) {
                                    if (val >= 0.9) {
                                      setState(() => _slideValue = 1.0);
                                      _onSlideComplete();
                                    } else {
                                      setState(() => _slideValue = 0.0);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}