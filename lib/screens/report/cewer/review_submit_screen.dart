import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:police/services/auth_service.dart';
import 'package:police/screens/report/cewer/report_successfully.dart';

class ReviewSubmitScreen extends StatefulWidget {
  final int reportId;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> filePaths;

  const ReviewSubmitScreen({
    super.key,
    required this.reportId,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.filePaths,
  });

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  bool _isSubmitting = false;

  Future<void> _onSubmitReport() async {
    setState(() => _isSubmitting = true);

    try {
      // ✅ Token optional — null = anonymous
      final token = await AuthService.getAccessToken();

      final uri = Uri.parse(
        '${AuthService.baseUrl}/api/cewer-reports/${widget.reportId}/submit/',
      );

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // ✅ Only send auth if logged in
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': 'submitted'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final referenceNumber =
            'CEWER-${DateTime.now().year}-${widget.reportId.toString().padLeft(5, '0')}';

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReportSuccessScreen(
              referenceNumber: referenceNumber,
            ),
          ),
        );
      } else {
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

  String _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(ext)) return 'photo';
    if (['mp4', 'mov', 'avi', 'wmv', 'mkv'].contains(ext)) return 'video';
    if (['mp3', 'wav', 'm4a', 'aac'].contains(ext)) return 'audio';
    return 'file';
  }

  IconData _getFileIcon(String path) {
    final type = _getFileType(path);
    if (type == 'photo') return Icons.image_outlined;
    if (type == 'video') return Icons.videocam_outlined;
    if (type == 'audio') return Icons.audiotrack_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review & Submit',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'INCIDENT DETAILS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFF1A237E),
                    label: 'CATEGORY',
                    value: widget.category,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'LOCATION',
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://static-maps.yandex.ru/1.x/?ll=${widget.longitude},${widget.latitude}&z=13&size=80,80&l=map&pt=${widget.longitude},${widget.latitude},pm2rdm',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.map,
                          color: Color(0xFF1A237E),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.address,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'EVIDENCE ATTACHED',
              child: widget.filePaths.isEmpty
                  ? const Text(
                      'No evidence attached',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.filePaths.map((path) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFDDDDDD),
                            ),
                          ),
                          child: Icon(
                            _getFileIcon(path),
                            color: const Color(0xFF1A237E),
                            size: 30,
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _onSubmitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'SUBMIT REPORT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'By submitting, you confirm that the information is accurate to the best of your knowledge.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}