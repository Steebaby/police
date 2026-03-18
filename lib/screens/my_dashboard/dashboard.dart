import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

enum ApplicationStatus { underReview, completed, pending }

class ApplicationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final ApplicationStatus status;

  const ApplicationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

class ServiceStatusItem {
  final String title;
  final String reference;
  final String statusLabel;
  final double progress;
  final IconData icon;

  const ServiceStatusItem({
    required this.title,
    required this.reference,
    required this.statusLabel,
    required this.progress,
    required this.icon,
  });
}

class NotificationItem {
  final IconData icon;
  final bool isAlert;
  final String title;
  final String body;
  final String time;

  const NotificationItem({
    required this.icon,
    required this.isAlert,
    required this.title,
    required this.body,
    required this.time,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  final List<ApplicationItem> _applications = const [
    ApplicationItem(
      icon: Icons.description_outlined,
      title: 'Firearms License',
      subtitle: 'Submitted on Oct 2, 2023',
      status: ApplicationStatus.underReview,
    ),
    ApplicationItem(
      icon: Icons.check_circle_outline,
      title: 'Character Certificate',
      subtitle: 'Submitted on Oct 30, 2023',
      status: ApplicationStatus.completed,
    ),
  ];

  final List<ServiceStatusItem> _serviceStatuses = const [
    ServiceStatusItem(
      title: 'Police Clearance',
      reference: 'Ref: PC-90301-B',
      statusLabel: 'Processing',
      progress: 0.85,
      icon: Icons.verified_user_outlined,
    ),
    ServiceStatusItem(
      title: 'Road Traffic Offence',
      reference: 'Ref: RT-4453-TX',
      statusLabel: 'Case Registered',
      progress: 0.90,
      icon: Icons.traffic_outlined,
    ),
  ];

  final List<NotificationItem> _notifications = const [
    NotificationItem(
      icon: Icons.notifications_active_outlined,
      isAlert: true,
      title: 'Action Required: Document Missing',
      body: 'Please upload a copy of ID for the Firearms License application.',
      time: '2 HRS AGO',
    ),
    NotificationItem(
      icon: Icons.info_outline,
      isAlert: false,
      title: 'Appointment Scheduled',
      body: 'Your interview for Character Certificate is set for Oct 27th.',
      time: 'YESTERDAY',
    ),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Applications Submitted ──
            _SectionHeader(
              title: 'Applications Submitted',
              actionLabel: 'View All',
              onAction: () {},
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(_applications.length, (index) {
                  final app = _applications[index];
                  final isLast = index == _applications.length - 1;
                  return Column(
                    children: [
                      _ApplicationRow(item: app),
                      if (!isLast)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 22),

            // ── Service Status ──
            _SectionHeader(title: 'Service Status'),
            const SizedBox(height: 10),
            Column(
              children: _serviceStatuses.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ServiceStatusCard(item: s),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // ── Recent Notifications ──
            _SectionHeader(title: 'Recent Notifications'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(_notifications.length, (index) {
                  final notif = _notifications[index];
                  final isLast = index == _notifications.length - 1;
                  return Column(
                    children: [
                      _NotificationRow(item: notif),
                      if (!isLast)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // ── Update Profile Button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_outline,
                    color: Colors.white, size: 20),
                label: const Text(
                  'Update Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Security ID
            Center(
              child: Text(
                'Security ID: POL-2938-NKUN50',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTapped,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic_outlined),
            activeIcon: Icon(Icons.headset_mic),
            label: 'Contact Us',
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Application Row ──────────────────────────────────────────────────────────

class _ApplicationRow extends StatelessWidget {
  final ApplicationItem item;

  const _ApplicationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;
    Color badgeBorderColor;
    String badgeLabel;

    switch (item.status) {
      case ApplicationStatus.underReview:
        badgeLabel = 'Under Review';
        badgeColor = const Color(0xFFFFF8E1);
        badgeTextColor = const Color(0xFFE65100);
        badgeBorderColor = const Color(0xFFFFCC80);
        break;
      case ApplicationStatus.completed:
        badgeLabel = 'Completed';
        badgeColor = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF2E7D32);
        badgeBorderColor = const Color(0xFF81C784);
        break;
      case ApplicationStatus.pending:
        badgeLabel = 'Pending';
        badgeColor = const Color(0xFFF3E5F5);
        badgeTextColor = const Color(0xFF6A1B9A);
        badgeBorderColor = const Color(0xFFCE93D8);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: const Color(0xFF1A237E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeBorderColor, width: 0.8),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Status Card ──────────────────────────────────────────────────────

class _ServiceStatusCard extends StatelessWidget {
  final ServiceStatusItem item;

  const _ServiceStatusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.reference,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon,
                    color: const Color(0xFF1A237E), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: const Color(0xFFE8EAF6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1A237E)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.statusLabel,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(item.progress * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Notification Row ─────────────────────────────────────────────────────────

class _NotificationRow extends StatelessWidget {
  final NotificationItem item;

  const _NotificationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        item.isAlert ? const Color(0xFFE65100) : const Color(0xFF1565C0);
    final iconBgColor =
        item.isAlert ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: item.isAlert
                        ? const Color(0xFFBF360C)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
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