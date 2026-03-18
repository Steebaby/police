import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const OnlineServicesScreen(),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class ServiceItem {
  final IconData icon;
  final String title;
  final String description;

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnlineServicesScreen extends StatefulWidget {
  const OnlineServicesScreen({super.key});

  @override
  State<OnlineServicesScreen> createState() => _OnlineServicesScreenState();
}

class _OnlineServicesScreenState extends State<OnlineServicesScreen> {
  int _selectedNavIndex = 1;

  final List<ServiceItem> _services = const [
    ServiceItem(
      icon: Icons.directions_car_outlined,
      title: 'Check Drivers',
      description: 'Search and verify driver license information in the national database.',
    ),
    ServiceItem(
      icon: Icons.verified_user_outlined,
      title: 'Police Clearance Certificate',
      description: 'Request your certificate status.',
    ),
    ServiceItem(
      icon: Icons.search_outlined,
      title: 'Lost Property Reporting',
      description: 'Report or search for lost items.',
    ),
    ServiceItem(
      icon: Icons.directions_car,
      title: 'Driving Schools Portal',
      description: 'Manage driving school registrations.',
    ),
    ServiceItem(
      icon: Icons.security_outlined,
      title: 'Private Security Governance',
      description: 'Regulatory compliance portal.',
    ),
    ServiceItem(
      icon: Icons.build_outlined,
      title: 'Motor Vehicle Inspection',
      description: 'Schedule vehicle inspections.',
    ),
    ServiceItem(
      icon: Icons.receipt_long_outlined,
      title: 'Traffic Offence Inquiry',
      description: 'Check traffic violation records.',
    ),
    ServiceItem(
      icon: Icons.school_outlined,
      title: 'Police Colleges and Schools',
      description: 'Training institutions and resources.',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Online Services',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _ServiceCard(service: _services[index]);
        },
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
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'SERVICES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic_outlined),
            activeIcon: Icon(Icons.headset_mic),
            label: 'CONTACT US',
          ),
        ],
      ),
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF0FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service.icon,
              color: const Color(0xFF1A237E),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            service.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            service.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Start Service button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}