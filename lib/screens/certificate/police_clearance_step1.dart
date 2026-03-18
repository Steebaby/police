import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PoliceClearanceApp());
}

// ─────────────────────────────────────────────
//  API SERVICE
// ─────────────────────────────────────────────
class ApiService {
  // For Android emulator use 10.0.2.2
  // For real device use your PC IP e.g. http://192.168.1.100:8000
  static const String baseUrl = 'http://10.0.2.2:8000/api/clearance';

  Future<Map<String, dynamic>> submitApplication({
    required String fullName,
    required String phone,
    required String nidaNumber,
    required String purpose,
    required File passportPhoto,
    required File nidaCopy,
    required File introLetter,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/submit/');
      final request = http.MultipartRequest('POST', uri);

      // ── Text fields ──
      request.fields['full_name']   = fullName;
      request.fields['phone']       = phone;
      request.fields['nida_number'] = nidaNumber;
      request.fields['purpose']     = purpose;

      // ── File fields ──
      request.files.add(
          await http.MultipartFile.fromPath('passport_photo', passportPhoto.path));
      request.files.add(
          await http.MultipartFile.fromPath('nida_copy', nidaCopy.path));
      request.files.add(
          await http.MultipartFile.fromPath('intro_letter', introLetter.path));

      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);
      final body      = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': body};
      } else {
        return {'success': false, 'errors': body['errors'] ?? body};
      }
    } catch (e) {
      return {'success': false, 'errors': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getApplicationStatus(int appId) async {
    try {
      final uri      = Uri.parse('$baseUrl/status/$appId/');
      final response = await http.get(uri);
      final body     = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': body};
      }
      return {'success': false, 'errors': body};
    } catch (e) {
      return {'success': false, 'errors': e.toString()};
    }
  }
}

// ─────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────
class PoliceClearanceApp extends StatelessWidget {
  const PoliceClearanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Police Clearance Certificate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A6B),
        ),
      ),
      home: const Step1PersonalInfo(),
    );
  }
}

// ─────────────────────────────────────────────
//  STEP 1 — PERSONAL INFORMATION
// ─────────────────────────────────────────────
class Step1PersonalInfo extends StatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController    = TextEditingController();
  final _nidaController     = TextEditingController();

  String? _selectedPurpose;

  final List<String> _purposes = [
    'Employment',
    'Travel / Visa Application',
    'Immigration',
    'Adoption',
    'Business License',
    'Higher Education',
    'Other',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _nidaController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step2UploadDocuments(
            fullName: _fullNameController.text.trim(),
            phone:    _phoneController.text.trim(),
            nida:     _nidaController.text.trim(),
            purpose:  _selectedPurpose!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFEEF0F5),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Police Clearance Certificate',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A3A6B),
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(step: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 1: Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Please provide your details accurately as they appear on your legal documents.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7A8499),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Full Name'),
                    const SizedBox(height: 6),
                    _buildTextFormField(
                      controller: _fullNameController,
                      hintText: 'Enter your full name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Phone Number'),
                    const SizedBox(height: 6),
                    _buildTextFormField(
                      controller: _phoneController,
                      hintText: '+255XXXXXXXXX',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Phone number is required';
                        if (!v.trim().startsWith('+255')) return 'Phone must start with +255';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('NIDA Number'),
                    const SizedBox(height: 6),
                    _buildTextFormField(
                      controller: _nidaController,
                      hintText: '19XXXXXXXXXXXX',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'NIDA number is required';
                        if (v.trim().length < 8) return 'NIDA number is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Purpose of Certificate'),
                    const SizedBox(height: 6),
                    _buildDropdown(),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A6B),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: const Color(0xFF1A3A6B).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Continue to Step 2',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStepDots(currentIndex: 0),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNav(activeIndex: 1),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPurpose,
      hint: const Text(
        'Select purpose',
        style: TextStyle(color: Color(0xFFAAB0C0), fontSize: 14),
      ),
      items: _purposes
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF333333))),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedPurpose = v),
      validator: (v) => (v == null || v.isEmpty) ? 'Please select a purpose' : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7A8499)),
      decoration: _dropdownDecoration(),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

// ─────────────────────────────────────────────
//  STEP 2 — UPLOAD DOCUMENTS
// ─────────────────────────────────────────────
class Step2UploadDocuments extends StatefulWidget {
  final String fullName;
  final String phone;
  final String nida;
  final String purpose;

  const Step2UploadDocuments({
    super.key,
    required this.fullName,
    required this.phone,
    required this.nida,
    required this.purpose,
  });

  @override
  State<Step2UploadDocuments> createState() => _Step2UploadDocumentsState();
}

class _Step2UploadDocumentsState extends State<Step2UploadDocuments> {
  final ImagePicker _picker     = ImagePicker();
  final ApiService  _apiService = ApiService();
  final List<File?> _files      = [null, null, null];
  bool _isLoading               = false;

  final List<Map<String, dynamic>> _docs = [
    {
      'title':    'Passport Size Photo',
      'subtitle': 'Recent colour photo with blue background',
      'icon':     Icons.person_outline,
    },
    {
      'title':    'NIDA ID Copy',
      'subtitle': 'National ID – front and back',
      'icon':     Icons.badge_outlined,
    },
    {
      'title':    'Introduction Letter',
      'subtitle': 'From Local Government / Ward Office',
      'icon':     Icons.description_outlined,
    },
  ];

  Future<void> _pickFile(int index) async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _files[index] = File(picked.path));
    }
  }

  bool get _allUploaded => _files.every((f) => f != null);

  // ── Submit to Django + MariaDB ──
  void _onContinue() async {
    if (!_allUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.submitApplication(
      fullName:      widget.fullName,
      phone:         widget.phone,
      nidaNumber:    widget.nida,
      purpose:       widget.purpose,
      passportPhoto: _files[0]!,
      nidaCopy:      _files[1]!,
      introLetter:   _files[2]!,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final appId = result['data']['application_id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Application #$appId submitted successfully!'),
          backgroundColor: const Color(0xFF1A3A6B),
        ),
      );
      // TODO: Navigate to Step 3 / Payment passing appId
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (_) => Step3Payment(applicationId: appId),
      // ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${result['errors'].toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: const BackButton(),
        centerTitle: false,
        title: const Text(
          'Upload Supporting Documents',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(step: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please ensure all documents are clear and in PDF, PNG, or JPEG format (Max 5MB).',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8499),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

              

                  ...List.generate(_docs.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDocCard(i),
                    );
                  }),

                  const SizedBox(height: 4),
                  _buildStepDots(currentIndex: 1),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Continue to Payment Button ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6B),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF1A3A6B).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit & Continue to Payment',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(int index) {
    final doc        = _docs[index];
    final file       = _files[index];
    final isUploaded = file != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded
              ? const Color(0xFF4CAF50).withOpacity(0.4)
              : const Color(0xFFE2E5EF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E9F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(doc['icon'] as IconData,
                      color: Colors.indigo, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['title'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doc['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7A8499),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUploaded)
                  GestureDetector(
                    onTap: () => setState(() => _files[index] = null),
                    child: const Icon(Icons.cancel,
                        color: Colors.redAccent, size: 20),
                  ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => _pickFile(index),
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              height: 100,
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.shade50
                    : const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUploaded
                      ? Colors.green.shade300
                      : const Color(0xFFD1D5E0),
                  width: 1.5,
                ),
              ),
              child: isUploaded
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(file!,
                              width: 60, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 22),
                              const SizedBox(height: 4),
                              const Text(
                                'Uploaded successfully',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                file.path.split('/').last,
                                style: const TextStyle(
                                    fontSize: 10.5, color: Color(0xFF7A8499)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 30, color: Colors.grey.shade400),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to upload from gallery',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

Widget _buildProgressBar({required int step}) {
  final double progress = step == 1 ? 0.33 : 0.66;
  final String label    = step == 1 ? 'STEP 1 OF 3' : 'STEP 2 OF 3';
  final String percent  = step == 1 ? '33% Complete' : '66% Complete';

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A6B),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              percent,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE2E5EF),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF1A3A6B)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStepDots({required int currentIndex}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: index == currentIndex ? 22 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: index == currentIndex
              ? const Color(0xFF1A3A6B)
              : const Color(0xFFD1D5E0),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

Widget _buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: Color(0xFF444444),
      letterSpacing: 0.1,
    ),
  );
}

Widget _buildTextFormField({
  required TextEditingController controller,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFAAB0C0), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E5EF), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E5EF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11.5, color: Color(0xFFE05252)),
    ),
  );
}

InputDecoration _dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E5EF), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E5EF), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
    ),
    errorStyle: const TextStyle(fontSize: 11.5, color: Color(0xFFE05252)),
  );
}

Widget _buildBottomNav({required int activeIndex}) {
  final items = [
    {'icon': Icons.home_outlined,        'label': 'HOME'},
    {'icon': Icons.description_outlined, 'label': 'SERVICES'},
    {'icon': Icons.chat_bubble_outline,  'label': 'CONTACT US'},
  ];

  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFEEF0F5), width: 1)),
    ),
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (i) {
        final isActive = i == activeIndex;
        final color =
            isActive ? const Color(0xFF1A3A6B) : const Color(0xFFAAB0C0);
        return GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(items[i]['icon'] as IconData, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                items[i]['label'] as String,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}