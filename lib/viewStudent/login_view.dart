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
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ISPGAYA Scalable Text Logo
                      Text(
                        'ISPGAYA',
                        style: TextStyle(
                          color: const Color(0xFFEE7A23),
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
                          color: Color(0xFFEE7A23), // ISPGAYA orange
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
                          fillColor: Colors.grey.shade200,
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
                          fillColor: Colors.grey.shade200,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEE7A23), // ISPGAYA orange
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () async {
                            final email = _email.text.trim();
                            final password = _password.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill in both fields."),
                                ),
                              );
                              return;
                            }

                            try {
                              // Logowanie użytkownika w Firebase Authentication
                              UserCredential userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);

                              final user = userCredential.user;
                              if (user != null) {
                                // Odczytaj rolę użytkownika z Firestore
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                                if (userDoc.exists) {
                                  final role = userDoc.data()?['role'];

                                  if (role == 'student') {
                                    // Przekierowanie na ekran studenta
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePageView(),
                                      ),
                                    );
                                  } else if (role == 'prof') {
                                    // Przekierowanie na ekran administratora
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfDashboard(), // Utwórz ekran admina
                                      ),
                                    );
                                  } else if (role == 'admin') {
                                    // Przekierowanie na ekran administratora
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminDashboard(), // Utwórz ekran admina
                                      ),
                                    );
                                  } else {
                                    // Jeśli rola nie jest zdefiniowana, pokaż błąd
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("User role is not defined."),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("User data not found."),
                                    ),
                                  );
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message ?? "Invalid email or password."),
                                ),
                              );
                            }
                          },
                          child: const Text(
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEE7A23)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GuestView(title: 'Guest'),
                              ),
                            );
                          },
                          child: const Text(
                            "I'm a guest",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFEE7A23),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
}
