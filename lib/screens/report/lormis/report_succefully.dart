import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportSuccessfullyScreen extends StatefulWidget {
  final String controlNumber;
  final String payerName;
  final String date;
  final String jurisdiction;

  const ReportSuccessfullyScreen({
    super.key,
    required this.controlNumber,
    required this.payerName,
    this.date = '',
    this.jurisdiction = 'Dodoma Central',
  });

  @override
  State<ReportSuccessfullyScreen> createState() =>
      _ReportSuccessfullyScreenState();
}

class _ReportSuccessfullyScreenState
    extends State<ReportSuccessfullyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String get _displayDate {
    if (widget.date.isNotEmpty) return widget.date;
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Preparing PDF download...'),
        backgroundColor: const Color(0xFF1A2A6C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // ── Success Icon ──
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF43A047).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF43A047),
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Title ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Report Successfully Filed for\n${widget.payerName}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A237E),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Subtitle ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Your lost property report has been recorded in our system. You can track the status using your reference number.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A93B2),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Reference Card ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE8ECF4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1A2A6C)
                                      .withOpacity(0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Reference No
                                _InfoRow(
                                  label: 'Reference No',
                                  value: widget.controlNumber,
                                  isFirst: true,
                                  valueStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                const Divider(
                                    height: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color(0xFFF0F2F8)),
                                // Date
                                _InfoRow(
                                  label: 'Date',
                                  value: _displayDate,
                                ),
                                const Divider(
                                    height: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color(0xFFF0F2F8)),
                                // Jurisdiction
                                _InfoRow(
                                  label: 'Jurisdiction',
                                  value: widget.jurisdiction,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Buttons ──
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Download PDF button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: _downloadPDF,
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Download Copy (PDF)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A2A6C),
                                  side: const BorderSide(
                                      color: Color(0xFFCDD3E8), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Return to Dashboard button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A2A6C),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: const Text(
                                  'Return to Dashboard',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Nav ──
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A6C).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: false,
                  onTap: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst)),
              _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Services',
                  active: true,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.headset_mic_rounded,
                  label: 'Contact Us',
                  active: false,
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: isFirst ? 18 : 14,
        bottom: isLast ? 18 : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A93B2),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF1A2A6C) : const Color(0xFF8A93B2);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight:
                  active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}