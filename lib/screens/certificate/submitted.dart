import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  STEP 5 — APPLICATION SUBMITTED
// ─────────────────────────────────────────────
class Step5ApplicationSubmitted extends StatelessWidget {
  final String referenceNumber;
  final String applicantEmail;

  const Step5ApplicationSubmitted({
    super.key,
    this.referenceNumber = 'PCC-2026-00342',
    this.applicantEmail = '',
  });

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
          'Application Submitted',
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
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                children: [
                  // ── Success Icon ──
                  _buildSuccessIcon(),
                  const SizedBox(height: 28),

                  // ── Title ──
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Subtitle ──
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF7A8499),
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(text: 'Your application for '),
                        TextSpan(
                          text: 'Police Clearance\nCertificate',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A3A6B),
                          ),
                        ),
                        TextSpan(text: ' has been successfully\nsubmitted.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Reference Number Box ──
                  _buildReferenceBox(),
                  const SizedBox(height: 20),

                  // ── Download Button ──
                  _buildDownloadButton(context),
                  const SizedBox(height: 16),

                  // ── Email notice ──
                  Text(
                    applicantEmail.isNotEmpty
                        ? 'A confirmation email has been sent to $applicantEmail.'
                        : 'A confirmation email has been sent to your\nregistered address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Step dots ──
                  _buildStepDots(),
                  const SizedBox(height: 8),

                  // ── Step label ──
                  const Text(
                    '5 of 5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3A6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom Nav ──
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Animated Success Icon ─────────────────────────────────────────────────
  Widget _buildSuccessIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(0.08),
          ),
        ),
        // Middle ring
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(0.15),
          ),
        ),
        // Inner filled circle
        Container(
          width: 66,
          height: 66,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4CAF50),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 34,
          ),
        ),
      ],
    );
  }

  // ── Reference Number Box ──────────────────────────────────────────────────
  Widget _buildReferenceBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E5EF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'REFERENCE NUMBER',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAB0C0),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            referenceNumber,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A3A6B),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Download Button ───────────────────────────────────────────────────────
  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: implement PDF download / share
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preparing your PDF...'),
              backgroundColor: Color(0xFF1A3A6B),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.download_outlined, size: 20),
        label: const Text(
          'Download Application Copy\n(PDF)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3A6B),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF1A3A6B).withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── Step Dots ─────────────────────────────────────────────────────────────
  Widget _buildStepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isActive = index == 4;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1A3A6B)
                : const Color(0xFFD1D5E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'HOME'},
      {'icon': Icons.description_outlined, 'label': 'SERVICES'},
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
          final isActive = i == 1; // SERVICES is active
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
}