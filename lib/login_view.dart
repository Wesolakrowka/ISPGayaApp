import 'package:applicationispgaya/firebase_options.dart';
import 'package:applicationispgaya/guest_view.dart';
import 'package:applicationispgaya/viewStudent/home_page_view.dart';
import 'package:applicationispgaya/viewAdmin/admin_dashboard.dart';
import 'package:applicationispgaya/viewProf/prof_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginView extends StatefulWidget {
  final String title;

  const LoginView({super.key, required this.title});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isLoading = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Stack(
              children: [
                // 📷 Obraz tła (dodaj swój obraz do folderu assets)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3, // Możesz dostosować przezroczystość
                    child: Image.asset(
                      "assets/1-44.jpg", // Ścieżka do pliku w katalogu assets
                      fit: BoxFit.cover, // Dopasowanie obrazu do szerokości
                    ),
                  ),
                ),

                // 📋 Formularz logowania na wierzchu
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo ISPGAYA
                        Text(
                          'ISPGAYA',
                          style: TextStyle(
                            color: const Color(0xFFFA8742),
                            fontSize: MediaQuery.of(context).size.width * 0.15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Instituto Superior Politécnico',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 150),

                        const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Color(0xFFFA8742),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email TextField
                        TextField(
                          controller: _email,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.email, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Password TextField
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: _buttonStyle(),
                            onPressed: _isLoading ? null : _loginUser,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Guest Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: _outlinedButtonStyle(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GuestView(),
                                ),
                              );
                            },
                            child: const Text(
                              "I'm a guest",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFFA8742),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    ),
  );
}

  // Styl dla pomarańczowego przycisku "Login"
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFA8742),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFFF26600); // Zmiana koloru na #F26600 po naciśnięciu
          }
          return null;
        },
      ),
    );
  }

  // Styl dla białego przycisku "I'm a guest"
  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFFFA8742)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFFF26600).withOpacity(0.3); // Lżejszy efekt po naciśnięciu
          }
          return null;
        },
      ),
    );
  }

  // Metoda logowania użytkownika
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'];

          if (role == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePageView()),
            );
          } else if (role == 'prof') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfDashboard()),
            );
          } else if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Invalid email or password.")),
      );
    }

    setState(() => _isLoading = false);
  }
}
