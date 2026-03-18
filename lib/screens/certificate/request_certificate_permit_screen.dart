import 'package:flutter/material.dart';
import 'package:police/screens/certificate/police_clearance_step1.dart'; // ← import yako ya Step 1

class RequestCertificatePermitScreen extends StatelessWidget {
  const RequestCertificatePermitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F7),

      /// AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "Request Certificate and Permit",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            const Text(
              "AVAILABLE SERVICES",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

            /// Police Clearance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                  )
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Icon Box
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xffE7E9F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Police Clearance Certificate",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Official document certifying your criminal record status (Good Conduct Certificate).",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [

                            /// Available Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Available Now",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                ),
                              ),
                            ),

                            const Spacer(),

                            /// Apply Button — NAVIGATION IMEONGEZWA HAPA
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Step1PersonalInfo(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Apply Now",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 12)
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Firearms Permit Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Firearms Permit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Digital application for firearm licensing and annual renewal permits.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "COMING SOON",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Help Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffE9EBF4),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Row(
                children: [

                  Icon(Icons.info_outline, color: Colors.indigo),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Need help with your application? Visit our help center or contact our 24/7 support line from the Contact Us tab.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}