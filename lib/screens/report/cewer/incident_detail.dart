import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:police/screens/report/cewer/location_selection.dart';
import 'package:police/services/auth_service.dart';

class IncidentReportApp extends StatelessWidget {
  const IncidentReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Report',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IncidentDetailsScreen(reportId: 0),
    );
  }
}

class IncidentDetailsScreen extends StatefulWidget {
  final int reportId;
  const IncidentDetailsScreen({super.key, required this.reportId});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  final List<String> _categories = [
    'Select a category',
    'Theft',
    'Accident',
    'Harassment',
    'Other',
  ];

  String _selectedCategory = 'Select a category';
  final TextEditingController _descriptionController = TextEditingController();
  final List<File> _uploadedFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthService.getAccessToken();
    setState(() => _isLoggedIn = token != null);
  }

  Future<void> _onUploadPhoto() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      _showPermissionDenied('Photo library');
      return;
    }
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _uploadedFiles.add(File(pickedFile.path)));
    }
  }

  Future<void> _onUploadVideo() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      _showPermissionDenied('Photo library');
      return;
    }
    final XFile? pickedFile =
        await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _uploadedFiles.add(File(pickedFile.path)));
    }
  }

  Future<void> _onUploadAudio() async {
    final audioStatus = await Permission.audio.request();
    final storageStatus = await Permission.storage.request();

    if (!audioStatus.isGranted && !storageStatus.isGranted) {
      _showPermissionDenied('Audio');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _uploadedFiles.add(File(result.files.single.path!)));
    }
  }

  void _showPermissionDenied(String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$permissionName permission denied')),
    );
  }

  void _deleteFile(int index) {
    setState(() => _uploadedFiles.removeAt(index));
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove File'),
        content: const Text('Are you sure you want to remove this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteFile(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == 'Select a category') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an incident category')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide an incident description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ✅ Token optional — null = anonymous
      final token = await AuthService.getAccessToken();

      final uri = Uri.parse('${AuthService.baseUrl}/api/cewer-reports/');
      final request = http.MultipartRequest('POST', uri);

      // ✅ Only send auth if logged in
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['category'] = _selectedCategory;
      request.fields['description'] = _descriptionController.text.trim();

      for (final file in _uploadedFiles) {
        final multipartFile =
            await http.MultipartFile.fromPath('files', file.path);
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;

        final responseData = jsonDecode(response.body);
        final int reportId = responseData['report_id'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LocationSelectionScreen(
              reportId: reportId,
              category: _selectedCategory,
              description: _descriptionController.text.trim(),
              filePaths: _uploadedFiles.map((f) => f.path).toList(),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildPreviewForFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) {
      return Image.file(file, fit: BoxFit.cover, width: 90, height: 90);
    } else if (['mp4', 'mov', 'avi', 'wmv', 'mkv'].contains(ext)) {
      return const Icon(Icons.videocam, size: 40, color: Colors.white);
    } else if (['mp3', 'wav', 'm4a', 'aac'].contains(ext)) {
      return const Icon(Icons.audiotrack, size: 40, color: Colors.white);
    } else {
      return const Icon(Icons.insert_drive_file, size: 40, color: Colors.white);
    }
  }

  String _getFileLabel(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) return 'Photo';
    if (['mp4', 'mov', 'avi', 'wmv', 'mkv'].contains(ext)) return 'Video';
    if (['mp3', 'wav', 'm4a', 'aac'].contains(ext)) return 'Audio';
    return 'File';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: [
            // ── Anonymous / Logged in Banner ──────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoggedIn
                    ? const Color(0xFFE8EAF6)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isLoggedIn
                      ? const Color(0xFF1A237E).withOpacity(0.2)
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoggedIn
                        ? Icons.verified_user_outlined
                        : Icons.privacy_tip_outlined,
                    color: _isLoggedIn
                        ? const Color(0xFF1A237E)
                        : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoggedIn
                              ? 'Submitting as Registered User'
                              : 'Anonymous Reporting',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _isLoggedIn
                                ? const Color(0xFF1A237E)
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isLoggedIn
                              ? 'This report will be linked to your account.'
                              : 'Your identity will remain completely private. No personal details will be recorded.',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Incident Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 20),
            const Text('Incident Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Provide as much detail as possible about what happened...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Upload Evidence',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                UploadButton(
                    label: 'PHOTO',
                    icon: Icons.camera_alt,
                    onPressed: _onUploadPhoto),
                UploadButton(
                    label: 'VIDEO',
                    icon: Icons.videocam,
                    onPressed: _onUploadVideo),
                UploadButton(
                    label: 'AUDIO',
                    icon: Icons.mic,
                    onPressed: _onUploadAudio),
              ],
            ),
            const SizedBox(height: 20),
            if (_uploadedFiles.isEmpty)
              const Text('No evidence uploaded yet.',
                  textAlign: TextAlign.center)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_uploadedFiles.length} file(s) attached',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        List.generate(_uploadedFiles.length, (index) {
                      final file = _uploadedFiles[index];
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  _buildPreviewForFile(file),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getFileLabel(file),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _showDeleteConfirmation(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Next Step',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const UploadButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}