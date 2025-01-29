// Importing necessary packages for Firebase, Flutter, and application-specific views
import 'package:applicationispgaya/firebase_options.dart'; // Firebase configuration options
import 'package:applicationispgaya/viewStudent/home_page_view.dart'; // Importing the home page view for students
import 'package:applicationispgaya/viewAdmin/admin_dashboard.dart'; // Importing the admin dashboard view
import 'package:applicationispgaya/viewProf/prof_dashboard.dart'; // Importing the professor dashboard view
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user login
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core for initialization
import 'package:flutter/material.dart'; // Importing Flutter material design components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database access
import 'package:applicationispgaya/guest/main_guest.dart'; // Importing the guest home view

// LoginView is a StatefulWidget that represents the login screen
class LoginView extends StatefulWidget {
  final String title; // Title of the login view

  // Constructor for LoginView, requires a title
  const LoginView({super.key, required this.title});

  @override
  State<LoginView> createState() => _LoginViewState(); // Creating the state for LoginView
}

// _LoginViewState is the state class for LoginView
class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email; // Controller for the email input field
  late final TextEditingController _password; // Controller for the password input field
  bool _isLoading = false; // Loading state for the login process

  @override
  void initState() {
    // Initializing the text controllers for email and password
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState(); // Calling the superclass's initState
  }

  @override
  void dispose() {
    // Disposing of the text controllers to free up resources
    _email.dispose();
    _password.dispose();
    super.dispose(); // Calling the superclass's dispose
  }

  @override
  Widget build(BuildContext context) {
    // Building the login screen UI
    return Scaffold(
      body: FutureBuilder(
        // FutureBuilder to handle Firebase initialization
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform, // Using default Firebase options
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done: // Firebase initialization complete
              return GestureDetector(
                // Dismiss keyboard on tap
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: [
                    Positioned.fill(
                      // Background image for the login screen
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/1-44.jpg"), // Background image asset
                            fit: BoxFit.cover, // Cover the entire screen
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), // Darken the image
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50), // Padding for the content
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // Centering the content
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ISPGAYA', // Title of the application
                                style: TextStyle(
                                  color: const Color(0xFFFA8742), // Title color
                                  fontSize: MediaQuery.of(context).size.width * 0.13, // Responsive font size
                                  fontWeight: FontWeight.bold, // Bold font weight
                                ),
                                textAlign: TextAlign.center, // Center align the text
                              ),
                              Text(
                                'Instituto Superior Politécnico', // Subtitle
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9), // Subtitle color
                                  fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                                ),
                                textAlign: TextAlign.center, // Center align the text
                              ),
                              const SizedBox(height: 100), // Spacer

                              const Text(
                                'LOGIN', // Login section title
                                style: TextStyle(
                                  color: Colors.white, // Title color
                                  fontSize: 28, // Font size
                                  fontWeight: FontWeight.bold, // Bold font weight
                                ),
                              ),
                              const SizedBox(height: 30), // Spacer

                              // Email text field
                              _buildTextField(
                                controller: _email, // Controller for email input
                                hintText: "Email", // Hint text for email field
                                icon: Icons.email, // Email icon
                                isPassword: false, // Not a password field
                              ),
                              const SizedBox(height: 15), // Spacer

                              // Password text field
                              _buildTextField(
                                controller: _password, // Controller for password input
                                hintText: "Password", // Hint text for password field
                                icon: Icons.lock, // Lock icon
                                isPassword: true, // This is a password field
                              ),
                              const SizedBox(height: 25), // Spacer

                              // Login button
                              _buildButton(
                                label: 'Login', // Button label
                                onPressed: _isLoading ? null : _loginUser, // Disable if loading
                                isPrimary: true, // Primary button style
                              ),
                              const SizedBox(height: 15), // Spacer

                              // Guest login button
                              _buildButton(
                                label: "I'm a guest", // Button label
                                onPressed: () {
                                  // Navigate to guest home view
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const GuestHomeView(), // Guest home view
                                    ),
                                  );
                                },
                                isPrimary: false, // Secondary button style
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
              return const Center(child: CircularProgressIndicator()); // Show loading indicator while initializing
          }
        },
      ),
    );
  }

  // Function to build a text field for input
  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, required bool isPassword}) {
    return TextField(
      controller: controller, // Text editing controller
      obscureText: isPassword, // Obscure text if it's a password field
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress, // Set keyboard type
      style: const TextStyle(color: Colors.white), // Text color
      decoration: InputDecoration(
        hintText: hintText, // Hint text for the field
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Hint text style
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)), // Icon in the text field
        filled: true, // Fill the background
        fillColor: Colors.white.withOpacity(0.2), // Background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          borderSide: BorderSide.none, // No border
        ),
      ),
    );
  }

  // Function to build a button
  Widget _buildButton({required String label, required VoidCallback? onPressed, required bool isPrimary}) {
    return SizedBox(
      width: double.infinity, // Full width button
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFFA8742) : Colors.white, // Button color based on type
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding
        ),
        onPressed: onPressed, // Button action
        child: Text(
          label, // Button label
          style: TextStyle(fontSize: 18, color: isPrimary ? Colors.white : const Color(0xFFFA8742)), // Text color based on type
        ),
      ),
    );
  }

  // Function to handle user login
  Future<void> _loginUser() async {
    setState(() => _isLoading = true); // Set loading state to true

    final email = _email.text.trim(); // Get trimmed email input
    final password = _password.text.trim(); // Get trimmed password input

    // Check if email or password fields are empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields.")), // Show error message
      );
      setState(() => _isLoading = false); // Reset loading state
      return; // Exit the function
    }

    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user; // Get the user from the credential
      if (user != null) {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role']; // Get user role from document

          // Navigate to different views based on user role
          if (role == 'student') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageView())); // Student view
          } else if (role == 'prof') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfDashboard())); // Professor view
          } else if (role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard())); // Admin view
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Invalid email or password."))); // Show error message
    }

    setState(() => _isLoading = false); // Reset loading state
  }
}