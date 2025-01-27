import 'package:flutter/material.dart';
import 'package:applicationispgaya/guest/degrees_guest.dart';
import 'package:applicationispgaya/guest/school_info_page.dart';
import 'package:applicationispgaya/login_view.dart'; // Import Login View

class GuestHomeView extends StatelessWidget {
  const GuestHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📷 Background Image
          Positioned.fill(
            child: Image.asset("assets/2.jpg", fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // 🏫 Title Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      "Welcome to ISPGAYA",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 📜 Introduction Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSection(
                    title: "About ISPGAYA",
                    content: "The Instituto Superior Politécnico de Gaya (ISPGAYA) was established in 1990 in Vila Nova de Gaia, Portugal. Our mission is to deliver high-quality higher education, fostering the development of well-rounded professionals equipped for the job market.",
                  ),
                ),

                // 📌 Navigation Buttons
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuButton(context, "Degrees", const DegreesPage()),
                      _buildMenuButton(context, "School Information", const SchoolInfoPage()),
                    ],
                  ),
                ),

                // 🔙 Back to Login Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFFA8742)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView(title: "Login")),
                        );
                      },
                      child: const Text("← Back to Login", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Styled Menu Buttons
  Widget _buildMenuButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  // 📌 Styled Section Box
  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(content, textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}
