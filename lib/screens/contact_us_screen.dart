import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  /// Real phone call launcher
  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open social media URL
  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      const SizedBox(height: 10),

      /// Safety Card
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Safety is Our Priority",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2473),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Contact us to report any activities or violations "
              "affecting your personal safety or public security. "
              "Our specialised teams are ready to intervene "
              "around the clock.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            /// 911 Button — real call
            GestureDetector(
              onTap: () => _makeCall('111'),
              child: _callButton(
                icon: Icons.warning_amber_outlined,
                text: "Call 111 For emergencies",
              ),
            ),
            const SizedBox(height: 15),

            /// 901 Button — real call
            GestureDetector(
              onTap: () => _makeCall('112'),
              child: _callButton(
                icon: Icons.call,
                text: "Call 112 For other inquiries",
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 30),

      /// Request Support
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Request Support",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2473),
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SupportItem(icon: Icons.person, title: "Women\nProtection"),
            SupportItem(icon: Icons.person_outline, title: "Child\nProtection"),
            SupportItem(icon: Icons.menu_book, title: "Tourist\nSupport"),
            SupportItem(icon: Icons.calendar_today, title: "Events\nSecurity"),
          ],
        ),
      ),

      const SizedBox(height: 30),

      /// ── Contact Info ──
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _contactInfoItem(
              icon: Icons.email_outlined,
              text: "info@tpf.go.tz",
            ),
            _divider(),
            _contactInfoItem(
              icon: Icons.person_outline,
              text: "Officer at your service",
            ),
            _divider(),
            _contactInfoItem(
              icon: Icons.headset_mic_outlined,
              text: "General Assistance",
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      /// ── Find Nearest Station ──
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Color(0xFF1E2473), size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Find the Nearest Tanzania Police\nStations",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2473),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Color(0xFF1E2473)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap here to quickly locate and navigate to the nearest\nTanzania Police Station.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            /// Station Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_police,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Police Post - Main Branch",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E2473),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Dar es Salaam, 255\nDistance: 2.5 km",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2473),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "FIND",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      /// ── Social Media ──
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Social Media",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2473),
          ),
        ),
      ),

      const SizedBox(height: 16),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
          children: [
            // Facebook
            _SocialItem(
              icon: Icons.facebook,
              iconColor: const Color(0xFF1877F2),
              name: "Facebook",
              followers: "129K Likes",
              onTap: () => _openUrl('https://www.facebook.com/tanzaniapoliceforce'),
            ),
            // Instagram — real link
            _SocialItem(
              icon: Icons.camera_alt_outlined,
              iconColor: const Color(0xFFE1306C),
              name: "Instagram",
              followers: "63K Followers",
              onTap: () => _openUrl('https://www.instagram.com/tanzaniapoliceforce'),
            ),
            // X (Twitter)
            _SocialItem(
              icon: Icons.close,
              iconColor: Colors.black,
              name: "X",
              followers: "89K Followers",
              onTap: () => _openUrl('https://www.twitter.com/PoliceForce_TZ'),
            ),
            // Youtube
            _SocialItem(
              icon: Icons.play_circle_fill,
              iconColor: Colors.red,
              name: "Youtube",
              followers: "46K Subscribers",
              onTap: () => _openUrl('https://www.youtube.com/@tanzaniapoliceforce'),
            ),
          ],
        ),
      ),

      const SizedBox(height: 30),
    ];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  /// Call Button Widget
  Widget _callButton({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E2473)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E2473)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2473),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E2473), size: 20),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 50, endIndent: 16);
  }
}

/// Support Item Widget
class SupportItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const SupportItem({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF1E2473), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF333333),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Social Media Item Widget
class _SocialItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String followers;
  final VoidCallback onTap;

  const _SocialItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.followers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E2473),
                    ),
                  ),
                  Text(
                    followers,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Navigation Item
class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const BottomItem({
    Key? key,
    required this.icon,
    required this.label,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF1E2473) : Colors.grey,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xFF1E2473) : Colors.grey,
          ),
        )
      ],
    );
  }
}