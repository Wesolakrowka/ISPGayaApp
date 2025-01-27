import 'package:flutter/material.dart';
import 'home_page_view.dart';
import 'schedule.dart';
import 'personal.dart';

class Degrees extends StatelessWidget {
  final String title;

  const Degrees({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Menu
          Container(
            color: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ISPGAYA',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    _buildMenuButton(context, 'Home page', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePageView(),
                        ),
                      );
                    }),
                    
                    _buildMenuButton(context, 'Schedule', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Schedule(), // Removed const keyword
                        ),
                      );
                    }),
                    _buildMenuButton(context, 'Personal data', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalData(), // Removed title parameter
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Page Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Degrees and Training Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Degrees and training',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // CTeSP Section
                  _buildSection(
                    'CTeSP',
                    'Our CTeSP are focused on a very practical teaching aspect, with guaranteed internship and the possibility of progression to one of our degrees without exams.',
                    'Start registration',
                  ),

                  const SizedBox(height: 20),

                  // Degrees Section
                  _buildSection(
                    'Degrees',
                    'Our degrees focus on academic rigor and practical applicability, preparing students for professional excellence.',
                  ),

                  const SizedBox(height: 20),

                  // Masters Section
                  _buildSection(
                    'Masters',
                    'Our master’s programs provide advanced expertise in diverse fields, empowering students for leadership roles.',
                  ),

                  const SizedBox(height: 20),

                  // Contacts Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.grey.shade200,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contacts:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Av. dos Descobrimentos, 333\n'
                          '4400-103 Santa Marinha - V.N.Gaia\n'
                          '(+351) 223 745 730\n'
                          'info@ispgaya.pt',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, [String? linkText]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(fontSize: 14),
        ),
        if (linkText != null)
          Align(
            alignment: Alignment.topRight,
            child: Text(
              linkText,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
