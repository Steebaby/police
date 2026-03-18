import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  STEP 3 — REVIEW AND PAY
// ─────────────────────────────────────────────
class Step3ReviewAndPay extends StatefulWidget {
  final String fullName;
  final String referenceNumber;
  final double serviceFee;

  const Step3ReviewAndPay({
    super.key,
    required this.fullName,
    required this.referenceNumber,
    this.serviceFee = 30000,
  });

  @override
  State<Step3ReviewAndPay> createState() => _Step3ReviewAndPayState();
}

class _Step3ReviewAndPayState extends State<Step3ReviewAndPay> {
  String _selectedPayment = 'mobile_money'; // 'mobile_money' or 'card'
  bool _isLoading = false;

  void _onConfirmPayment() async {
    setState(() => _isLoading = true);

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildSuccessDialog(),
    );
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
          'Review and Pay',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A3A6B),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Progress Bar ──
          _buildProgressBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Application Summary Card ──
                  _buildSummaryCard(),
                  const SizedBox(height: 24),

                  // ── Payment Method ──
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    value: 'mobile_money',
                    title: 'Pay via Mobile Money',
                    subtitle: 'M-Pesa, Tigo Pesa, Airtel Money',
                    icon: Icons.phone_android_outlined,
                  ),
                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    value: 'card',
                    title: 'Pay via Card',
                    subtitle: 'Visa, Mastercard, Maestro',
                    icon: Icons.credit_card_outlined,
                  ),

                  const SizedBox(height: 20),

                  // ── Terms notice ──
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'By proceeding with the payment, you agree to the\nTanzanian Police Force terms of service and processing fees.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Step Dots ──
                  _buildStepDots(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Confirm Payment Button ──
          _buildBottomButton(),

          // ── Bottom Nav ──
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Progress Bar ─────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'APPLICATION PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A6B),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A6B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Step 3 of 3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 6,
              backgroundColor: Color(0xFFE2E5EF),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3A6B)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Application Summary Card ──────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E5EF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Text(
                  'Application Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A6B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),

          // Applicant Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E9F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF1A3A6B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Police Clearance Certificate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8499),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),

          // Fee + Control Number
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                  label: 'Service Fee',
                  value: 'Tzs ${_formatAmount(widget.serviceFee)}',
                  valueStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A6B),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSummaryRow(
                  label: 'Control Number',
                  value: widget.referenceNumber,
                  valueStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF7A8499),
          ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }

  // ── Payment Option Card ───────────────────────────────────────────────────
  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A3A6B)
                : const Color(0xFFE2E5EF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1A3A6B).withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A3A6B)
                    : const Color(0xFFEEF0F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF7A8499),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1A3A6B)
                          : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF7A8499),
                    ),
                  ),
                ],
              ),
            ),

            // Check icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1A3A6B),
                      size: 22,
                      key: ValueKey('checked'),
                    )
                  : Container(
                      key: const ValueKey('unchecked'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFD1D5E0), width: 1.5),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step Dots ─────────────────────────────────────────────────────────────
  Widget _buildStepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == 2 ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == 2
                ? const Color(0xFF1A3A6B)
                : const Color(0xFFD1D5E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Bottom Confirm Button ─────────────────────────────────────────────────
  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onConfirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3A6B),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF1A3A6B).withOpacity(0.6),
            elevation: 4,
            shadowColor: const Color(0xFF1A3A6B).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· Tzs ${_formatAmount(widget.serviceFee)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'HOME'},
      {'icon': Icons.payment_outlined, 'label': 'PAYMENT'},
      {'icon': Icons.chat_bubble_outline, 'label': 'CONTACT US'},
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
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.5,
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
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF1A3A6B),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
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
              'Your application has been submitted.\nReference: ${widget.referenceNumber}',
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
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}