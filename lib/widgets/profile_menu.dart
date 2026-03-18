import 'package:flutter/material.dart';
import 'package:police/screens/create_account_screen.dart';
import 'package:police/screens/login_screen.dart'; // ← IMEONGEZWA

// ── Full Page Profile Menu ────────────────────────────────────
class ProfileMenuPage extends StatelessWidget {
  const ProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tanzania Police Force',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'SOS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                color: Color(0xFF1A237E), size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ── Stay Connected Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Connected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Get the latest events and directly update all info from the home.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 18),

                  // ── Sign in with your Account → LoginScreen ── ✅
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A237E),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign in with your Account',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Visitor Create Account → CreateAccountScreen ── ✅
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white60, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Visitor Create Account',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Profile Section Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Sign in to start your session → LoginScreen ── ✅
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign in to start your session',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Menu Items Card ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                  _ProfileMenuItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.route_outlined,
                    label: 'Walkthrough',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.info_outline,
                    label: 'About Us',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Information & Procedure',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.language,
                    label: 'Change Language',
                    trailingText: 'EN',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.lock_outline,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.article_outlined,
                    label: 'Terms & Conditions',
                    isLast: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item Widget ──────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool isLast;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          leading: Icon(icon, color: const Color(0xFF1A237E), size: 22),
          title: Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
          trailing: trailingText != null
              ? Text(
                  trailingText!,
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                )
              : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 18,
              endIndent: 18,
              color: Colors.grey[200]),
      ],
    );
  }
}