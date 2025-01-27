import 'package:applicationispgaya/firebase_options.dart';
import 'package:applicationispgaya/viewStudent/home_page_view.dart';
import 'package:applicationispgaya/viewAdmin/admin_dashboard.dart';
import 'package:applicationispgaya/viewProf/prof_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:applicationispgaya/guest/main_guest.dart';

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
      child: Scaffold(
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Stack(
                  children: [
                    // 🌄 Background Image with Light Blur
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), // Lighter overlay
                          BlendMode.darken,
                        ),
                        child: Image.asset(
                          "assets/1-44.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 📋 Login Form
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 🏛️ Logo
                              Text(
                                'ISPGAYA',
                                style: TextStyle(
                                  color: const Color(0xFFFA8742),
                                  fontSize: MediaQuery.of(context).size.width * 0.12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Instituto Superior Politécnico',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 50),

                              // 🔐 "LOGIN" Title
                              const Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Color(0xFFFA8742),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ✉️ Email Input
                              _buildTextField(_email, "Email", Icons.email),
                              const SizedBox(height: 15),

                              // 🔒 Password Input
                              _buildTextField(_password, "Password", Icons.lock, obscureText: true),
                              const SizedBox(height: 25),

                              // 🔘 Login Button
                              _buildButton(
                                label: "Login",
                                onPressed: _isLoading ? null : _loginUser,
                                isPrimary: true,
                              ),
                              const SizedBox(height: 15),

                              // 🏛️ Guest Button
                              _buildButton(
                                label: "I'm a guest",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const GuestHomeView()),
                                  );
                                },
                                isPrimary: false,
                              ),
                            ],
                          ),
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
      ),
    );
  }

  // 🔤 Text Field Widget
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: obscureText ? TextInputType.visiblePassword : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔘 Button Widget
  Widget _buildButton({required String label, required VoidCallback? onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isPrimary ? const Color(0xFFFA8742) : Colors.white,
          ),
          foregroundColor: WidgetStateProperty.all(
            isPrimary ? Colors.white : const Color(0xFFFA8742),
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isPrimary
                  ? BorderSide.none
                  : const BorderSide(color: Color(0xFFFA8742)),
            ),
          ),
        ),
        onPressed: onPressed,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  // 🚀 Login User Method
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in both fields.");
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

          Widget nextPage = switch (role) {
            "student" => const HomePageView(),
            "prof" => const ProfDashboard(),
            "admin" => const AdminDashboard(),
            _ => const GuestHomeView(),
          };

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Invalid email or password.");
    }

    setState(() => _isLoading = false);
  }

  // ⚠️ Show Error Messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
