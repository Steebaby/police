import 'package:flutter/material.dart';

class ReviewSubmitScreen extends StatelessWidget {
  const ReviewSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F7),

      appBar: AppBar(
        title: const Text("Review & Submit"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Step Text
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Step 3 of 3: Final Review",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 1,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 20),

            /// Summary Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F8FB),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ListView(
                  children: [

                    const Text(
                      "Report Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Reporter Details
                    _summarySection(
                      icon: Icons.person,
                      title: "Reporter Details",
                      children: const [
                        _summaryRow("Full Name", "Jonathan Mkumbu"),
                        _summaryRow("Contact", "+255 700 000 000"),
                      ],
                    ),

                    /// Lost Item
                    _summarySection(
                      icon: Icons.phone_iphone,
                      title: "Lost Item",
                      children: const [
                        _summaryRow("Item Name", "iPhone 13 Pro"),
                        _summaryRow("Category", "Electronics"),
                        _summaryRow("Color", "Sierra Blue"),
                      ],
                    ),

                    /// Time & Place
                    _summarySection(
                      icon: Icons.location_on,
                      title: "Time & Place",
                      children: const [
                        _summaryRow("Location", "Dodoma, Tanzania"),
                        _summaryRow("Date", "Oct 25, 2023"),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Report submitted successfully!"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Submit & Get Control Number",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Contact Us",
          ),
        ],
      ),
    );
  }

  /// Summary Section Widget
  Widget _summarySection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12.withOpacity(0.05),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...children
        ],
      ),
    );
  }
}

/// Row Widget
class _summaryRow extends StatelessWidget {

  final String label;
  final String value;

  const _summaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}