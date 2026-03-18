import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recent History',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RecentHistoryScreen(),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

enum OffenceStatus { pending, paid }

class OffenceRecord {
  final String title;
  final String plateNumber;
  final OffenceStatus status;
  final double amount;
  final String location;
  final String dateTime;
  final IconData icon;

  const OffenceRecord({
    required this.title,
    required this.plateNumber,
    required this.status,
    required this.amount,
    required this.location,
    required this.dateTime,
    required this.icon,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RecentHistoryScreen extends StatefulWidget {
  const RecentHistoryScreen({super.key});

  @override
  State<RecentHistoryScreen> createState() => _RecentHistoryScreenState();
}

class _RecentHistoryScreenState extends State<RecentHistoryScreen> {
  int _selectedNavIndex = 1;

  final List<OffenceRecord> _records = const [
    OffenceRecord(
      title: 'Speeding',
      plateNumber: 'T 123 ABC',
      status: OffenceStatus.pending,
      amount: 30000,
      location: 'Dodoma',
      dateTime: '24 Oct 2023, 14:30 PM',
      icon: Icons.speed,
    ),
    OffenceRecord(
      title: 'Wrong Parking',
      plateNumber: 'T 123 ABC',
      status: OffenceStatus.paid,
      amount: 20000,
      location: 'Dodoma',
      dateTime: '10 Oct 2023, 09:15 AM',
      icon: Icons.local_parking,
    ),
    OffenceRecord(
      title: 'Expired License',
      plateNumber: 'T 123 ABC',
      status: OffenceStatus.paid,
      amount: 50000,
      location: 'Dar es Salaam',
      dateTime: '12 Sep 2023, 11:45 AM',
      icon: Icons.credit_card_off_outlined,
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
          'Recent History',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _records.isEmpty
          ? const Center(
              child: Text(
                'No records found.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OffenceCard(record: _records[index]);
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

// ─── Offence Card ─────────────────────────────────────────────────────────────

class _OffenceCard extends StatelessWidget {
  final OffenceRecord record;

  const _OffenceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPending = record.status == OffenceStatus.pending;

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
          // ── Top row: icon + title/plate + status badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  record.icon,
                  color: const Color(0xFF1A237E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title + plate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.plateNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(isPending: isPending),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          // ── Bottom row: amount + location ──
          Row(
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'AMOUNT',
                  value: 'TZS ${_formatAmount(record.amount)}',
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'LOCATION',
                  value: record.location,
                  alignRight: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Date row ──
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Colors.black45,
              ),
              const SizedBox(width: 5),
              Text(
                record.dateTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(formatted[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isPending;

  const _StatusBadge({required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFFB74D)
              : const Color(0xFF81C784),
          width: 0.8,
        ),
      ),
      child: Text(
        isPending ? 'PENDING' : 'PAID',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isPending
              ? const Color(0xFFE65100)
              : const Color(0xFF2E7D32),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Info Column ──────────────────────────────────────────────────────────────

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}