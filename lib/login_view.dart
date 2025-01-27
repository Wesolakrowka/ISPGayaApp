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
    return Scaffold(
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(), // Ukrycie klawiatury
                child: Stack(
                  children: [
                    // 🔥 Obraz tła (widoczniejszy, ale przyciemniony dla czytelności)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/1-44.jpg"),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), // Przyciemnienie
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 🟠 Formularz logowania
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🏫 Logo ISPGAYA
                              Text(
                                'ISPGAYA',
                                style: TextStyle(
                                  color: const Color(0xFFFA8742),
                                  fontSize: MediaQuery.of(context).size.width * 0.13,
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
                              const SizedBox(height: 100),

                              const Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // 📧 Email TextField
                              _buildTextField(
                                controller: _email,
                                hintText: "Email",
                                icon: Icons.email,
                                isPassword: false,
                              ),
                              const SizedBox(height: 15),

                              // 🔑 Password TextField
                              _buildTextField(
                                controller: _password,
                                hintText: "Password",
                                icon: Icons.lock,
                                isPassword: true,
                              ),
                              const SizedBox(height: 25),

                              // 🟠 Login Button
                              _buildButton(
                                label: 'Login',
                                onPressed: _isLoading ? null : _loginUser,
                                isPrimary: true,
                              ),
                              const SizedBox(height: 15),

                              // 🤵 Guest Button
                              _buildButton(
                                label: "I'm a guest",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const GuestHomeView(),
                                    ),
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
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // 🔹 Komponent: Pole tekstowe
  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, required bool isPassword}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔹 Komponent: Przycisk
  Widget _buildButton({required String label, required VoidCallback? onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFFA8742) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 18, color: isPrimary ? Colors.white : const Color(0xFFFA8742)),
        ),
      ),
    );
  }

  // 🔹 Metoda logowania użytkownika
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageView()));
          } else if (role == 'prof') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfDashboard()));
          } else if (role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Invalid email or password.")));
    }

    setState(() => _isLoading = false);
  }
}
