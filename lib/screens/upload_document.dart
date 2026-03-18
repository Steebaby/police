import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  File? _passportPhoto;
  File? _nidaCopy;
  File? _introLetter;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile(int docIndex) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        if (docIndex == 0) _passportPhoto = File(picked.path);
        if (docIndex == 1) _nidaCopy = File(picked.path);
        if (docIndex == 2) _introLetter = File(picked.path);
      });
    }
  }

  void _removeFile(int docIndex) {
    setState(() {
      if (docIndex == 0) _passportPhoto = null;
      if (docIndex == 1) _nidaCopy = null;
      if (docIndex == 2) _introLetter = null;
    });
  }

  File? _getFile(int index) {
    if (index == 0) return _passportPhoto;
    if (index == 1) return _nidaCopy;
    if (index == 2) return _introLetter;
    return null;
  }

  bool get _allUploaded =>
      _passportPhoto != null && _nidaCopy != null && _introLetter != null;

  void _onContinue() {
    if (!_allUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // Navigate to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to Payment...'),
        backgroundColor: Color(0xFF1A3A6B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = [
      {
        'title': 'Passport Size Photo',
        'subtitle': 'Recent colour photo with blue background',
        'icon': Icons.person_outline,
      },
      {
        'title': 'NIDA ID Copy',
        'subtitle': 'National ID – front and back',
        'icon': Icons.badge_outlined,
      },
      {
        'title': 'Introduction Letter',
        'subtitle': 'From Local Government / Ward Office',
        'icon': Icons.description_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: const BackButton(),
        title: const Text(
          'Upload Supporting Documents',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          _buildProgressBar(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
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

                  // Document Cards
                  ...List.generate(docs.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDocumentCard(
                        title: docs[index]['title'] as String,
                        subtitle: docs[index]['subtitle'] as String,
                        icon: docs[index]['icon'] as IconData,
                        index: index,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Continue Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STEP 2 OF 3',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A6B),
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '66% Complete',
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
              value: 0.66,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E5EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A3A6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int index,
  }) {
    final file = _getFile(index);
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
          // Card Header
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
                  child: Icon(icon, color: Colors.indigo, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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
                    onTap: () => _removeFile(index),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Upload Area
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
                  style: BorderStyle.solid,
                ),
              ),
              child: isUploaded
                  ? _buildUploadedPreview(file!, index)
                  : _buildUploadPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 30,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 6),
        Text(
          'Click to upload or drag and drop',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedPreview(File file, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: 60,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
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
                  fontSize: 10.5,
                  color: Color(0xFF7A8499),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3A6B),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF1A3A6B).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue to Payment',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}