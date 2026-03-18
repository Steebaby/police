import 'package:flutter/material.dart';
import 'package:police/screens/report/lormis/lost_property_step2_screen.dart';
import 'package:police/services/report_service.dart'; // ← adjust path if needed
import 'package:police/helpers/report_step_manager.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost Property Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LostPropertyReportScreen(reportId: 1,),
    );
  }
}

class LostPropertyReportScreen extends StatefulWidget {
    final int reportId;
  const LostPropertyReportScreen({super.key, required this.reportId});

  @override
  State<LostPropertyReportScreen> createState() =>
      _LostPropertyReportScreenState();
}

class _LostPropertyReportScreenState extends State<LostPropertyReportScreen> {
  String? _selectedCategory;
  bool _isLoading = false; // ← track loading state

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _estimatedValueController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Accessories',
    'Documents',
    'Bags & Luggage',
    'Keys',
    'Jewelry',
    'Other',
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _estimatedValueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Lost Property Report',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: 1, totalSteps: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _FormLabel(text: 'Item Category'),
                  const SizedBox(height: 8),
                  _CategoryDropdown(
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 20),

                  _FormLabel(text: 'Item Name/Model'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _itemNameController,
                    hintText: 'e.g. iPhone 13 Pro, Leather Wallet',
                  ),
                  const SizedBox(height: 20),

                  _FormLabel(text: 'Estimated Value (Tsh)'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _estimatedValueController,
                    hintText: 'Tsh  0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixText: null,
                  ),
                  const SizedBox(height: 20),

                  _FormLabel(text: 'Item Description'),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _descriptionController,
                    hintText:
                        'Describe unique features, color,\nmarks, or content inside...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF1A237E).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue to Step 2',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  // ── UPDATED: saves to database before going to Step 2 ──────────────────────
  void _onContinue() async {
    // Validate fields
    if (_selectedCategory == null) {
      _showSnack('Please select an item category.');
      return;
    }
    if (_itemNameController.text.trim().isEmpty) {
      _showSnack('Please enter the item name/model.');
      return;
    }

    // Show loading spinner on button
    setState(() => _isLoading = true);

    // Submit to Django → MariaDB
    final result = await ReportService.submitLostPropertyStep1(
      category:       _selectedCategory!,
      itemName:       _itemNameController.text.trim(),
      estimatedValue: _estimatedValueController.text.trim(),
      description:    _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
       await ReportStepManager.saveStep(2, result['report_id']);
      _showSnack('Report saved! ✅', color: Colors.green);

      // Pass report_id to Step 2 so it can update the same record
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LostPropertyStep2Screen(
            reportId: result['report_id'],
          ),
        ),
      );
    } else {
      _showSnack(result['message'] ?? 'Something went wrong.');
    }
  }

  void _showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index < currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF1A237E)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < totalSteps - 1) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Step $currentStep of $totalSteps',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Label ───────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}

// ─── Category Dropdown ────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Select category',
            style: TextStyle(color: Colors.black45, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Styled Text Field ────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;
  final String? prefixText;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixText: prefixText,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.black45,
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Contact Us',
          ),
        ],
      ),
    );
  }
}