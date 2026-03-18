import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  PAY FINE SCREEN
// ─────────────────────────────────────────────
class PayFineScreen extends StatefulWidget {
  final double outstandingAmount;

  const PayFineScreen({
    super.key,
    this.outstandingAmount = 80000,
  });

  @override
  State<PayFineScreen> createState() => _PayFineScreenState();
}

class _PayFineScreenState extends State<PayFineScreen> {
  String _selectedMethod = 'mpesa';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _mobileMethods = [
    {
      'id': 'mpesa',
      'name': 'M-Pesa',
      'subtitle': 'Vodacom Tanzania',
      'letter': 'M',
      'color': const Color(0xFF4CAF50),
      'letterColor': Colors.white,
    },
    {
      'id': 'tigo',
      'name': 'Tigo Pesa',
      'subtitle': 'Tigo Tanzania',
      'letter': 'T',
      'color': const Color(0xFF1565C0),
      'letterColor': Colors.white,
    },
    {
      'id': 'airtel',
      'name': 'Airtel Money',
      'subtitle': 'Airtel Tanzania',
      'letter': 'A',
      'color': const Color(0xFFE53935),
      'letterColor': Colors.white,
    },
  ];

  void _onConfirm() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildSuccessDialog(),
    );
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFEEF0F5),
        leading: const BackButton(color: Color(0xFF1A3A6B)),
        centerTitle: true,
        title: const Text(
          'Pay Fine',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A3A6B),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Total Outstanding Banner ──
                  _buildAmountBanner(),

                  const SizedBox(height: 24),

                  // ── Payment Methods Label ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Mobile Money Group ──
                  _buildPaymentGroup(),

                  const SizedBox(height: 12),

                  // ── Bank Transfer ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildBankTransferOption(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom section ──
          _buildBottomSection(),

          // ── Bottom Nav ──
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Amount Banner ─────────────────────────────────────────────────────────
  Widget _buildAmountBanner() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7A8499),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TZS ${_formatAmount(widget.outstandingAmount)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A3A6B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Money Group Card ───────────────────────────────────────────────
  Widget _buildPaymentGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E5EF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group label
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'MOBILE MONEY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Options
            ...List.generate(_mobileMethods.length, (i) {
              final method = _mobileMethods[i];
              final isLast = i == _mobileMethods.length - 1;
              return Column(
                children: [
                  _buildMobileMoneyOption(method),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: Color(0xFFF0F1F5),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Single Mobile Money Option ────────────────────────────────────────────
  Widget _buildMobileMoneyOption(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method['id']),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Letter avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: method['color'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  method['letter'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: method['letterColor'] as Color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF7A8499),
                    ),
                  ),
                ],
              ),
            ),

            // Radio
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ── Bank Transfer Option ──────────────────────────────────────────────────
  Widget _buildBankTransferOption() {
    final isSelected = _selectedMethod == 'bank';

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = 'bank'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E5EF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Bank icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF1A3A6B),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Name + subtitle
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Transfer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Direct deposit or Wire',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF7A8499),
                    ),
                  ),
                ],
              ),
            ),

            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  // ── Radio Button ──────────────────────────────────────────────────────────
  Widget _buildRadio(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF1A3A6B) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF1A3A6B) : const Color(0xFFD1D5E0),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.circle, color: Colors.white, size: 10)
          : null,
    );
  }

  // ── Bottom Section ────────────────────────────────────────────────────────
  Widget _buildBottomSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        children: [
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _onConfirm,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.lock_outline, size: 18),
              label: Text(
                _isLoading ? 'Processing...' : 'Confirm Payment',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF1A3A6B).withOpacity(0.6),
                elevation: 4,
                shadowColor: const Color(0xFF1A3A6B).withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 11, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                'Secure encrypted payment processing',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.grid_view_outlined, 'label': 'Services'},
      {'icon': Icons.phone_outlined, 'label': 'Contact Us'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF0F5), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = i == 1;
          final color =
              isActive ? const Color(0xFF1A3A6B) : const Color(0xFFAAB0C0);
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i]['icon'] as IconData, color: color, size: 22),
                const SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Success Dialog ────────────────────────────────────────────────────────
  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your fine of TZS ${_formatAmount(widget.outstandingAmount)}\nhas been paid successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7A8499),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}