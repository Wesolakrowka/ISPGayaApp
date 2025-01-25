import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applicationispgaya/login_view.dart';
import 'package:applicationispgaya/messages/contacts_view.dart';
import 'package:applicationispgaya/viewStudent/schedule.dart';

class ProfDashboard extends StatelessWidget {
  const ProfDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📷 Obraz tła na całą stronę
          Positioned.fill(
            child: Image.asset(
              "assets/2.jpg", // Ścieżka do obrazu w assets
              fit: BoxFit.cover,
            ),
          ),

          // 📋 Główna zawartość
          SafeArea(
            child: Column(
              children: [
                // 🟠 Logo i tytuł
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'ISPGAYA',
                        style: TextStyle(
                          color: const Color(0xFFFA8742),
                          fontSize: MediaQuery.of(context).size.width * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Instituto Superior Politécnico',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔘 Przyciskowa Sekcja
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMenuButton(context, label: 'Schedule', route: Schedule()),
                        const SizedBox(height: 20),

                        _buildMenuButton(context, label: 'Messages', route: ContactsView()),
                        const SizedBox(height: 20),

                        // 🚪 Logout Button
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: _logoutButtonStyle(),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(title: 'Login'),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(fontSize: 18, color: Color(0xFFFA8742)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📌 Sekcja Kontaktu (przyklejona na dole)
                Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contacts:',
                        style: TextStyle(
                          color: Color(0xFFFA8742),
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
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛠 Metoda do generowania przycisków
  Widget _buildMenuButton(BuildContext context, {required String label, required Widget route}) {
    return SizedBox(
      width: 350,
      child: OutlinedButton(
        style: _menuButtonStyle(),
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

  // 🎨 Styl dla przycisków menu
  ButtonStyle _menuButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: const Color(0xFFFA8742),
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFFA8742)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFFF26600);
          }
          return null;
        },
      ),
    );
  }

  // 🎨 Styl dla przycisku Logout
  ButtonStyle _logoutButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFFA8742),
      side: const BorderSide(color: Color(0xFFFA8742)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.red.withOpacity(0.1);
          }
          return null;
        },
      ),
    );
  }
}
