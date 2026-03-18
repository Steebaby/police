import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class PoliceClearanceScreen extends StatefulWidget {
  const PoliceClearanceScreen({super.key});

  @override
  State<PoliceClearanceScreen> createState() => _PoliceClearanceScreenState();
}

class _PoliceClearanceScreenState extends State<PoliceClearanceScreen> {
  Position? _userPosition;
  String _umbali = 'Inapakia...';
  bool _inapakia = true;

  // ── Coordinates za Central Police Station (Mlimani City, DSM)
  static const double _stationLat = -6.7714;
  static const double _stationLng = 39.2352;

  @override
  void initState() {
    super.initState();
    _pataEneo(); // pata eneo mara screen inafunguka
  }

  Future<void> _pataEneo() async {
    try {
      // Angalia GPS imewashwa
      bool imewashwa = await Geolocator.isLocationServiceEnabled();
      if (!imewashwa) {
        setState(() {
          _umbali = 'Washa GPS kwenye simu yako';
          _inapakia = false;
        });
        return;
      }

      // Angalia ruhusa
      LocationPermission ruhusa = await Geolocator.checkPermission();
      if (ruhusa == LocationPermission.denied) {
        ruhusa = await Geolocator.requestPermission();
        if (ruhusa == LocationPermission.denied) {
          setState(() {
            _umbali = 'Ruhusa imekataliwa';
            _inapakia = false;
          });
          return;
        }
      }

      if (ruhusa == LocationPermission.deniedForever) {
        setState(() {
          _umbali = 'Ruhusa imezuiwa kabisa';
          _inapakia = false;
        });
        return;
      }

      // ✅ Pata eneo la kweli
      Position nafasi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Hesabu umbali kutoka kwako hadi kituo cha polisi
      double meita = Geolocator.distanceBetween(
        nafasi.latitude,
        nafasi.longitude,
        _stationLat,
        _stationLng,
      );

      // Geuza kuwa km au meita
      String umbaliText;
      if (meita >= 1000) {
        double km = meita / 1000;
        umbaliText = '${km.toStringAsFixed(1)} km away';
      } else {
        umbaliText = '${meita.toStringAsFixed(0)} m away';
      }

      setState(() {
        _userPosition = nafasi;
        _umbali = umbaliText;
        _inapakia = false;
      });

    } catch (e) {
      setState(() {
        _umbali = 'Imeshindwa kupata eneo';
        _inapakia = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Police Clearance Certificate',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Police Clearance Card ──
                Container(
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
                        child: const Icon(Icons.badge_outlined,
                            color: Color(0xFF1A237E), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Police Clearance Certificate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Apply for your good conduct certificate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── What's New ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "What's New",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Horizontal News Cards ──
                SizedBox(
                  height: 230,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _NewsCard(
                        tag: 'FEATURED',
                        tagColor: const Color(0xFF1A237E),
                        backgroundColor: const Color(0xFFD4E8C2),
                        iconWidget: 'assets/images/police_help.png',
                        title: 'SMART SECURE TOGETHER',
                        subtitle:
                            'Our new community initiative focused on building a safer Tanzania through moder...',
                      ),
                      const SizedBox(width: 12),
                      _NewsCard(
                        tag: 'NEWS',
                        tagColor: const Color(0xFF0288D1),
                        backgroundColor: const Color(0xFF29B6F6),
                        icon: Icons.phone_android_outlined,
                        title: 'Digital Reporting',
                        subtitle:
                            'Report crimes from your device easily and quickly...',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Police Stations Near You ──
                const Text(
                  'Police Stations Near You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Map Card ──
                Container(
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
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Stack(
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              color: const Color(0xFFB2DFDB),
                              child: const Icon(
                                Icons.map_outlined,
                                size: 80,
                                color: Color(0xFF80CBC4),
                              ),
                            ),
                            // OPEN 24/7 badge
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF43A047),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'OPEN 24/7',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            // Station name overlay
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 48,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Central Police Station',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 4,
                                            color: Colors.black45)
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Mlimani City Drive-thru, Dar es Salaam',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 4,
                                            color: Colors.black45)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Navigate button
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.navigation_outlined,
                                  color: Color(0xFF1A237E),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ Distance & More Details — SASA NA GPS YA KWELI
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Color(0xFF1A237E)),
                                const SizedBox(width: 4),
                                // ✅ HAPA NDIPO UMBALI WA KWELI UNAONYESHWA
                                _inapakia
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF1A237E),
                                        ),
                                      )
                                    : Text(
                                        _umbali,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Text(
                                    'More Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      size: 18, color: Color(0xFF1A237E)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── News Card Widget ──────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final Color backgroundColor;
  final IconData? icon;
  final String? iconWidget;
  final String title;
  final String subtitle;

  const _NewsCard({
    required this.tag,
    required this.tagColor,
    required this.backgroundColor,
    this.icon,
    this.iconWidget,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  color: backgroundColor,
                  child: iconWidget != null
                      ? Image.asset(
                          iconWidget!,
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                        )
                      : Icon(icon, size: 60, color: Colors.white54),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}