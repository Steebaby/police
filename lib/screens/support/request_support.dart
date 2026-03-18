import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RequestSupportScreen(),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class SupportContact {
  final IconData icon;
  final String title;
  final String detail;
  final String? dialNumber; // null for email

  const SupportContact({
    required this.icon,
    required this.title,
    required this.detail,
    this.dialNumber,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RequestSupportScreen extends StatefulWidget {
  const RequestSupportScreen({super.key});

  @override
  State<RequestSupportScreen> createState() => _RequestSupportScreenState();
}

class _RequestSupportScreenState extends State<RequestSupportScreen> {
  int _selectedNavIndex = 2; // Contact Us tab

  final List<SupportContact> _contacts = const [
    SupportContact(
      icon: Icons.phone_outlined,
      title: 'Emergency Call Center',
      detail: '111 / 112',
      dialNumber: '112',
    ),
    SupportContact(
      icon: Icons.shield_outlined,
      title: 'IGP Call Center',
      detail: '+255 787 668 306',
      dialNumber: '+255787668306',
    ),
    SupportContact(
      icon: Icons.email_outlined,
      title: 'Police Email Support',
      detail: 'info.phs@tpf.go.tz',
      dialNumber: null,
    ),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedNavIndex = index);
  }

  Future<void> _onContactTap(SupportContact contact) async {
    final Uri uri;
    if (contact.dialNumber != null) {
      uri = Uri(scheme: 'tel', path: contact.dialNumber);
    } else {
      uri = Uri(scheme: 'mailto', path: contact.detail);
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Request Support',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon circle ──
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF1A237E),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ──
            const Text(
              'Emergency Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // ── Subtitle ──
            const Text(
              'Provides emergency communication\nchannels with the police.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── Contact Cards ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(_contacts.length, (index) {
                  final contact = _contacts[index];
                  final isLast = index == _contacts.length - 1;
                  return Column(
                    children: [
                      _ContactRow(
                        contact: contact,
                        onTap: () => _onContactTap(contact),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFF0F0F0),
                        ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // ── Info / disclaimer box ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'In case of an immediate life-threatening emergency, please use the Emergency Call Center numbers directly for faster response.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
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

// ─── Contact Row ──────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final SupportContact contact;
  final VoidCallback onTap;

  const _ContactRow({
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                contact.icon,
                color: const Color(0xFF1A237E),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Title + detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.detail,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}