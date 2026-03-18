import 'package:flutter/material.dart';
import 'package:police/screens/login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEEFF5), Color(0xFFDDE0F0), Color(0xFFEEEFF5)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      Image.asset(
                        'assets/images/logoPolice.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const Text(
                        'Tanzania Police Force App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E),
                        ),
                      ),

                      const SizedBox(height: 36),

                      const _FeatureItem(
                        icon: Icons.access_time_outlined,
                        title: 'Personalized Dashboard',
                        description: 'Status, applications, and records. Unified.',
                      ),
                      const SizedBox(height: 24),
                      const _FeatureItem(
                        icon: Icons.lock_outline,
                        title: 'Service Evolution',
                        description: 'Optimised services for direct access.',
                      ),
                      const SizedBox(height: 24),
                      const _FeatureItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Service Categorization',
                        description:
                            'New service categorization is designed for enhanced user understanding and friendliness.',
                      ),
                      const SizedBox(height: 24),
                      const _FeatureItem(
                        icon: Icons.description_outlined,
                        title: 'Make a Report Easier',
                        description:
                            'Reporting incidents made simple and quick for citizens.',
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Sign in to synchronise your profile, track requests, and\nview your standing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF555555),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Sign In Button → navigates to LoginScreen
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Sign in to start your session',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFBBBBBB))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: TextStyle(
                                    color: Color(0xFF888888), fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: Color(0xFFBBBBBB))),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ✅ Guest Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            final rootContext = context;

                            showDialog(
                              context: rootContext,
                              barrierDismissible: true,
                              builder: (BuildContext dialogContext) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEEF0FB),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_outline,
                                            size: 34,
                                            color: Color(0xFF1A237E),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Welcoming',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A237E),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'You are browsing as a guest.\nSome features may be limited.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: Color(0xFF555555),
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              Navigator.of(rootContext).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const HomeScreen(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1A237E),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: const Text(
                                              'Continue',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color(0xFF888888),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFDFF5E3),
                            foregroundColor: const Color(0xFF2E7D32),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 26, color: const Color(0xFF1A237E)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}