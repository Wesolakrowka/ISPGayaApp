import 'package:applicationispgaya/views/degrees.dart';
import 'package:applicationispgaya/views/payment.dart';
import 'package:applicationispgaya/views/personal.dart';
import 'package:applicationispgaya/views/schedule.dart';
import 'package:flutter/material.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Section
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            'ISPGAYA',
                            style: TextStyle(
                              color: const Color(0xFFEE7A23),
                              fontSize: MediaQuery.of(context).size.width * 0.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Instituto Superior Politécnico',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/group_img.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Buttons Section
                    _buildMenuButton(
                      context,
                      label: 'Schedule',
                      route: const Schedule(title: 'Schedule'),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuButton(
                      context,
                      label: 'Notifications/Payment',
                      route: const Payment(title: 'Payment'),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuButton(
                      context,
                      label: 'Degrees and Training',
                      route: const Degrees(title: 'Degrees'),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuButton(
                      context,
                      label: 'Personal Data/Grades',
                      route: const Personal(title: 'Personal'),
                    ),
                    const SizedBox(height: 30),

                    // News Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'NEWS:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNewsBlock(Colors.orange),
                          _buildNewsBlock(Colors.grey),
                          _buildNewsBlock(Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Contacts Section
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contacts:',
                    style: TextStyle(
                      color: Color(0xFFEE7A23),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Av. dos Descobrimentos, 333\n'
                    '4400-103 Santa Marinha - V.N.Gaia\n'
                    '(+351) 223 745 730\n'
                    'info@ispgaya.pt',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method for creating menu buttons
  Widget _buildMenuButton(BuildContext context, {required String label, required Widget route}) {
    return SizedBox(
      width: 350,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFEE7A23),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFEE7A23)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFEE7A23).withOpacity(0.8);
              }
              return null;
            },
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // Method for building news blocks
  Widget _buildNewsBlock(Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
