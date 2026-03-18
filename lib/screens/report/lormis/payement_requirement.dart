import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:police/screens/report/lormis/report_succefully.dart';
import 'package:police/services/report_service.dart';
import 'package:police/screens/report/lormis/report_succefully.dart';

class LostPropertyPaymentScreen extends StatefulWidget {
  final int reportId;
  final String controlNumber;
  final String payerName;

  const LostPropertyPaymentScreen({
    super.key,
    required this.reportId,
    required this.controlNumber,
    this.payerName = 'N/A',
  });

  @override
  State<LostPropertyPaymentScreen> createState() =>
      _LostPropertyPaymentScreenState();
}

class _LostPropertyPaymentScreenState
    extends State<LostPropertyPaymentScreen>
    with TickerProviderStateMixin {
  bool _copied = false;
  bool _isPaying = false;

  late AnimationController _cardAnimController;
  late AnimationController _fadeController;
  late Animation<double> _cardAnim;
  late Animation<double> _fadeAnim;

  static const String serviceName = 'Lost Property Report Fee';
  static const String amount = 'Tsh 1,000';

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _cardAnimController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _copyNumber() {
    Clipboard.setData(ClipboardData(text: widget.controlNumber));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Control number copied!'),
        backgroundColor: const Color(0xFF1A2A6C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // ── I Have Paid ───────────────────────────────────────────────────────────
  Future<void> _onHavePaid() async {
    setState(() => _isPaying = true);
    try {
      final result = await ReportService.submitPayment(
        reportId: widget.reportId,
        method: 'manual',
        phone: '',
        amount: 1000,
      );
      if (result['success']) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReportSuccessfullyScreen(
                controlNumber: widget.controlNumber,
                payerName: widget.payerName,
              ),
            ),
          );
        }
      } else {
        _snack(result['message'] ?? 'Could not confirm payment.');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A2A6C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lost Property Report',
          style: TextStyle(
            color: Color(0xFF1A2A6C),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child:
              Container(color: const Color(0xFFE8ECF4), height: 1),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Payment Required Banner ──
              _PaymentBanner(amount: amount),
              const SizedBox(height: 20),

              // ── Payment Details Card ──
              _DetailsCard(
                payerName: widget.payerName,
                serviceName: serviceName,
              ),
              const SizedBox(height: 20),

              // ── Government Control Number Card ──
              ScaleTransition(
                scale: _cardAnim,
                child: _ControlNumberCard(
                  controlNumber: widget.controlNumber,
                  copied: _copied,
                  onCopy: _copyNumber,
                ),
              ),
              const SizedBox(height: 28),

              // ── I Have Paid Button ──
              _PrimaryButton(
                label: 'I Have Paid',
                onPressed: _onHavePaid,
                loading: _isPaying,
              ),
              const SizedBox(height: 14),

              // ── Cancel Button ──
              _OutlineButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ── Payment Banner ────────────────────────────────────────────────────────────
class _PaymentBanner extends StatelessWidget {
  final String amount;
  const _PaymentBanner({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A6C).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'PAYMENT REQUIRED',
            style: TextStyle(
              color: Color(0xFF8A93B2),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF1A2A6C),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Details Card ──────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final String payerName;
  final String serviceName;
  const _DetailsCard(
      {required this.payerName, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A6C).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Payer', value: payerName),
          const Divider(
              height: 1,
              indent: 18,
              endIndent: 18,
              color: Color(0xFFF0F2F8)),
          _DetailRow(label: 'Service', value: serviceName),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFF8A93B2),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1A2A6C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Control Number Card ───────────────────────────────────────────────────────
class _ControlNumberCard extends StatelessWidget {
  final String controlNumber;
  final bool copied;
  final VoidCallback onCopy;

  const _ControlNumberCard({
    required this.controlNumber,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A2A6C),
            Color(0xFF2D4A9A),
            Color(0xFF3A6BC7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A6C).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -10,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Bank Icon
          Positioned(
            top: 18, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Government Control Number',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controlNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onCopy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 9),
                    decoration: BoxDecoration(
                      color: copied
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: copied
                            ? Colors.greenAccent.withOpacity(0.7)
                            : Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          copied ? Icons.check : Icons.copy,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          copied ? 'Copied!' : 'Copy Number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2A6C),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A2A6C).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                )),
      ),
    );
  }
}

// ── Outline Button ────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton(
      {required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A2A6C),
          side: const BorderSide(
              color: Color(0xFFCDD3E8), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            )),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2A6C).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: false,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Services',
                  active: true,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.headset_mic_rounded,
                  label: 'Contact Us',
                  active: false,
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF1A2A6C) : const Color(0xFF8A93B2);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}