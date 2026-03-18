import 'package:flutter/material.dart';
import 'package:police/screens/report/lormis/lost_property_step1_screen.dart';
import 'package:police/screens/report/cewer/incident_detail.dart';

class MakeReportScreen extends StatelessWidget {
  const MakeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Make a Report',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AVAILABLE REPORT TYPES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // ── Lost Property ─────────────────────────────────
            _ReportCard(
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF5B8CFF),
              iconBgColor: const Color(0xFFEEF2FF),
              title: 'Lost Property Report',
              description:
                  'Lost something important? Report missing items for recovery assistance.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LostPropertyReportScreen(reportId: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── CEWER ─────────────────────────────────────────
            _ReportCard(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF5B8CFF),
              iconBgColor: const Color(0xFFEEF2FF),
              title: 'Criminal Early Warning\nand Early Response',
              description:
                  'Submit official CEWER reports to help maintain a safer community.',
              badge: 'Anonymous allowed',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IncidentDetailsScreen(reportId: 0),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            _OfficialReportingToolBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final String? badge;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      height: 1.4,
                    ),
                  ),
                  // ✅ Anonymous badge
                  if (badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            size: 11,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Color(0xFFBDBDBD), size: 22),
          ],
        ),
      ),
    );
  }
}

class _OfficialReportingToolBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5B8CFF).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF5B8CFF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Official Reporting Tool',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D5AFE),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All reports are securely processed by the ITF. For anonymous or emergency reports, interested citizens can use the Emergency Alerts directly.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5B6BBF),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: false),
              _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'REPORTS',
                  isActive: true),
              _NavItem(
                  icon: Icons.person_outline,
                  label: 'PROFILE',
                  isActive: false),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final color =
        isActive ? const Color(0xFF5B8CFF) : const Color(0xFFBDBDBD);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}