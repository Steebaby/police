import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:police/screens/my_dashboard/dashboard.dart';
import 'package:police/screens/inquire/inquire_pay_services.dart';
import 'package:police/screens/explore/online_services_data.dart';
import 'package:police/screens/certificate/request_certificate_permit_screen.dart';
import 'package:police/screens/support/request_support.dart';
import 'package:police/widgets/profile_menu.dart';
import 'package:police/screens/sos_screen.dart';
import 'package:police/screens/certificate/police_clearance_screen.dart';
import 'package:police/screens/contact_us_screen.dart';
import 'package:police/screens/create_account_screen.dart';
import 'package:police/screens/login_screen.dart';
import 'package:police/screens/report/make_report_screen.dart'; // ✅ FIXED
import 'package:police/screens/certificate/request_certificate_permit_screen.dart'; // ✅ FIXED
import 'package:police/screens/inquire/inquire_pay_services.dart';

// ── Home Screen ───────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const ContactUsScreen(),
    const _ServicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SosScreen()),
              );
            },
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileMenuPage()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Contact Us'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Services'),
        ],
      ),
    );
  }
}

// ── Home Content ──────────────────────────────────────────────
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _showBanner = true;
  String _distanceText = 'Calculating...';
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showEnableLocationDialog();
      return;
    }
    await _checkPermissionAndLoad();
  }

  Future<void> _showEnableLocationDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Color(0xFF1A237E)),
            SizedBox(width: 8),
            Text(
              'Location is Off',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Please turn on your device location to find nearby police stations and get real-time distance.',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _distanceText = 'Location off';
                _locationLoading = false;
              });
            },
            child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              await Future.delayed(const Duration(seconds: 2));
              await _initLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Turn On Location'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPermissionAndLoad() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _distanceText = 'Permission denied';
          _locationLoading = false;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.location_disabled, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Permission Denied',
                style: TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Location permission is permanently denied. Please enable it from app settings.',
            style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _distanceText = 'Permission denied';
                  _locationLoading = false;
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }
    await _loadDistance();
  }

  Future<void> _loadDistance() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      const double stationLat = -6.7735;
      const double stationLng = 39.2694;
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, stationLat, stationLng,
      );
      String distanceStr = distanceInMeters < 1000
          ? '${distanceInMeters.toStringAsFixed(0)} m away'
          : '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
      setState(() {
        _distanceText = distanceStr;
        _locationLoading = false;
      });
    } catch (e) {
      setState(() {
        _distanceText = 'Could not get location';
        _locationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showBanner)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stay Connected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showBanner = false),
                            child: const Icon(Icons.close, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Get the latest alerts and safety updates directly from the force.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
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
                          ),
                          child: const Text('Sign in to start your session'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
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
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text(
                'I Would Like To',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  // ✅ FIXED - navigates to MakeReportScreen
                  _ActionItem(
                    icon: Icons.edit_document,
                    label: 'Make a Report',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MakeReportScreen()),
                      );
                    },
                  ),
                  _ActionItem(
                    icon: Icons.verified_outlined, 
                    label: 'Request Certificate & Permit',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestCertificatePermitScreen()),
                      );
                    },
                     ),
                  _ActionItem(icon: Icons.payment_outlined, label: 'Inquire & Pay',
                   onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InquirePayServicesScreen()),
                      );
                    },
                     ),
                  _ActionItem(icon: Icons.support_agent_outlined, label: 'Request Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestSupportScreen()),
                      );
                    },  
                  ),
                  _ActionItem(icon: Icons.grid_view_outlined, label: 'Explore Services',
                   onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnlineServicesScreen()),
                      );
                    },  ),
                  _ActionItem(icon: Icons.dashboard_outlined, label: 'My Dashboard',
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    }, 
                     ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const _ServiceCard(
                icon: Icons.receipt_long_outlined,
                title: 'Fines Inquiry and Payment',
                subtitle: 'Check and settle your traffic fines instantly',
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PoliceClearanceScreen()),
                  );
                },
                child: const _ServiceCard(
                  icon: Icons.badge_outlined,
                  title: 'Police Clearance Certificate',
                  subtitle: 'Apply for your good conduct certificate',
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Nearby Stations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2DFDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'OPEN 24/7',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Central Police Station',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Mlimani City Drive-thru, Dar es Salaam',
                                style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Color(0xFF1A237E)),
                                  const SizedBox(width: 4),
                                  if (_locationLoading)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A237E)),
                                    )
                                  else
                                    Text(
                                      _distanceText,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A237E), fontWeight: FontWeight.w500),
                                    ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _locationLoading = true;
                                        _distanceText = 'Calculating...';
                                      });
                                      _initLocation();
                                    },
                                    child: const Icon(Icons.refresh, size: 16, color: Color(0xFF1A237E)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.navigation, color: Color(0xFF1A237E)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'More Details >',
                          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Item ✅ FULLY FIXED ────────────────────────────────
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1A237E), size: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1A237E), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// ── Services Page ─────────────────────────────────────────────
class _ServicesPage extends StatelessWidget {
  const _ServicesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Services',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }
}