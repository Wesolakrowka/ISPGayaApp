import 'package:applicationispgaya/firebase_options.dart';
import 'package:applicationispgaya/views/guest_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('LOGIN'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: "Email"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(hintText: "Password"),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
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
                          final userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          print(userCredential);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login successful!"),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid email or password."),
                              ),
                            );}
                      },
                      
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),  // Odstęp między przyciskami
                    ElevatedButton(
                      onPressed: () {
                        // Po kliknięciu przenosi do strony rejestracji
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GuestView(title: 'Guest')),
                        );
                      },
                      child: const Text("I'm a guest"),
                    ),
                  ],
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
