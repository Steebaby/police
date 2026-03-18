import 'package:flutter/material.dart';
import 'package:police/services/report_service.dart';
import 'package:police/screens/report/lormis/payement_requirement.dart';
import 'package:police/helpers/report_step_manager.dart';


class LostPropertyStep3Screen extends StatefulWidget {
  final int reportId;
  const LostPropertyStep3Screen({super.key, required this.reportId});

  @override
  State<LostPropertyStep3Screen> createState() =>
      _LostPropertyStep3ScreenState();
}

class _LostPropertyStep3ScreenState
    extends State<LostPropertyStep3Screen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  // ── Load report from database ─────────────────────────────────────────────
  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data =
          await ReportService.getLostReportById(widget.reportId);
      if (mounted) {
        setState(() {
          _reportData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load report: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ── Submit final report ───────────────────────────────────────────────────
  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await ReportService.submitLostPropertyFinal(
        reportId: widget.reportId,
      );
      if (result['success']) {
         await ReportStepManager.clearProgress();
        if (mounted) {
          // ── Navigate to Payment screen ──
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LostPropertyPaymentScreen(
                reportId: widget.reportId,
                controlNumber:
                    result['control_number'] ?? 'LPR-000000',
                payerName:
                    _safe(_reportData?['reporter_name']),
              ),
            ),
          );
        }
      } else {
        _snack(result['message'] ?? 'Submission failed.');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _safe(String? value, {String fallback = 'N/A'}) =>
      (value != null && value.trim().isNotEmpty)
          ? value.trim()
          : fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review & Submit',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A237E)))
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────
  Widget _buildContent() {
    final data = _reportData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review your report before submitting.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // ── Item Details ──
          _SummaryCard(
            icon: Icons.inventory_2_outlined,
            title: 'Item Details',
            rows: [
              _SummaryRow(
                  label: 'Item Name',
                  value: _safe(data['item_name'])),
              _SummaryRow(
                  label: 'Category',
                  value: _safe(data['category'])),
              _SummaryRow(
                  label: 'Estimated Value',
                  value: data['estimated_value'] != null
                      ? 'Tsh ${data['estimated_value']}'
                      : 'N/A'),
              _SummaryRow(
                  label: 'Description',
                  value: _safe(data['description'])),
            ],
          ),
          const SizedBox(height: 12),

          // ── Location & Time ──
          _SummaryCard(
            icon: Icons.location_on_outlined,
            title: 'Location & Time',
            rows: [
              _SummaryRow(
                  label: 'Location',
                  value: _safe(data['location'])),
              _SummaryRow(
                  label: 'Landmark',
                  value: _safe(data['landmark'])),
              _SummaryRow(
                  label: 'Date Lost',
                  value: _safe(data['date_lost'])),
              _SummaryRow(
                  label: 'Time Lost',
                  value: _safe(data['time_lost'],
                      fallback: 'Not specified')),
            ],
          ),
          const SizedBox(height: 12),

          // ── Circumstances ──
          _SummaryCard(
            icon: Icons.notes_outlined,
            title: 'Circumstances',
            rows: [
              _SummaryRow(
                  label: 'What Happened',
                  value: _safe(data['circumstances'],
                      fallback: 'Not provided')),
            ],
          ),
          const SizedBox(height: 24),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF1A237E).withOpacity(0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Submitting...',
                            style: TextStyle(fontSize: 15)),
                      ],
                    )
                  : const Text(
                      'Submit & Get Control Number',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Edit Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A237E),
                side: const BorderSide(color: Color(0xFF1A237E)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Edit Report',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Step 3 of 3: Final Review',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                '100% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF43A047),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 4,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1A237E)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav Bar ────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: false),
              _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Services',
                  isActive: true),
              _NavItem(
                  icon: Icons.help_outline,
                  label: 'Contact Us',
                  isActive: false),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_SummaryRow> rows;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A237E), size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: row,
              )),
        ],
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9E9E9E))),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A237E),
              )),
        ),
      ],
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFF1A237E)
        : const Color(0xFFBDBDBD);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.normal)),
      ],
    );
  }
}