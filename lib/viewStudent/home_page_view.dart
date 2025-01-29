import 'package:flutter/material.dart'; // Importing Flutter's material design library for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user authentication
import 'package:applicationispgaya/login_view.dart'; // Importing the login view for user authentication
import 'package:applicationispgaya/messages/contacts_view.dart'; // Importing the contacts view for messaging functionality
import 'package:applicationispgaya/viewStudent/schedule.dart'; // Importing the schedule view for displaying user schedules
import 'package:applicationispgaya/viewStudent/personal.dart'; // Importing the personal data view for user information

// HomePageView is a StatelessWidget that represents the main view of the application for logged-in users
class HomePageView extends StatelessWidget {
  const HomePageView({super.key}); // Constructor for HomePageView

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold provides a structure for the visual interface
      body: Stack( // Stack allows for overlapping widgets
        children: [
          // Background Image
          Positioned.fill( // Fills the available space with the background image
            child: Image.asset(
              "assets/2.jpg", // Path to the background image
              fit: BoxFit.cover, // Ensures the image covers the entire area
            ),
          ),

          // Main Content
          SafeArea( // Ensures that the content is not obscured by system UI (like notches)
            child: Column( // Column arranges its children vertically
              children: [
                // Header Section
                Container( // Container is used to hold the header content
                  padding: const EdgeInsets.symmetric(vertical: 20), // Vertical padding for the header
                  child: Column( // Nested column for header text
                    children: [
                      Text(
                        'ISPGAYA', // Main title of the header
                        style: TextStyle(
                          color: const Color(0xFFFA8742), // Color of the title
                          fontSize: MediaQuery.of(context).size.width * 0.1, // Responsive font size based on screen width
                          fontWeight: FontWeight.bold, // Bold font weight
                        ),
                      ),
                      const SizedBox(height: 5), // Space between title and subtitle
                      Text(
                        'Instituto Superior Politécnico', // Subtitle of the header
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), // Slightly transparent white color
                          fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Space below the header

                // Buttons Section
                Expanded( // Expanded widget allows the buttons section to take up remaining space
                  child: SingleChildScrollView( // Enables scrolling if content overflows
                    child: Column( // Column to hold the menu buttons
                      children: [
                        _buildMenuButton(context, label: 'Schedule', route: Schedule()), // Button for Schedule
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Personal Data', route: const PersonalData()), // Button for Personal Data
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Messages', route: const ContactsView()), // Button for Messages
                        const SizedBox(height: 20), // Space between buttons

                        // 🚪 Logout Button
                        Padding( // Padding around the logout button
                          padding: const EdgeInsets.all(20), // All sides padding
                          child: SizedBox(
                            width: double.infinity, // Button takes full width
                            child: OutlinedButton( // Outlined button for logout
                              style: _logoutButtonStyle(), // Custom style for the logout button
                              onPressed: () async { // Asynchronous function for logout action
                                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                                Navigator.pushAndRemoveUntil( // Navigate to login view and remove all previous routes
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(title: 'Login'), // Login view
                                  ),
                                  (route) => false, // Remove all previous routes
                                );
                              },
                              child: const Text(
                                'Logout', // Text displayed on the button
                                style: TextStyle(fontSize: 18, color: Color(0xFFFA8742)), // Style for the button text
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact Section at the Bottom
                Container( // Container for the contact information
                  width: double.infinity, // Full width of the container
                  color: Colors.black.withOpacity(0.6), // Semi-transparent black background
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Padding for the contact section
                  child: const Column( // Column to hold contact information
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
                    children: [
                      Text(
                        'Contacts:', // Title for the contact section
                        style: TextStyle(
                          color: Color(0xFFFA8742), // Color for the contact title
                          fontWeight: FontWeight.bold, // Bold font weight
                          fontSize: 18, // Font size for the title
                        ),
                      ),
                      SizedBox(height: 5), // Space below the title
                      Text(
                        'Av. dos Descobrimentos, 333\n' // Address line 1
                        '4400-103 Santa Marinha - V.N.Gaia\n' // Address line 2
                        '(+351) 223 745 730\n' // Phone number
                        'info@ispgaya.pt', // Email address
                        style: TextStyle(fontSize: 12, color: Colors.white), // Style for the contact information
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

  // Create Menu Buttons
  Widget _buildMenuButton(BuildContext context, {required String label, required Widget route}) {
    return SizedBox( // SizedBox to set a specific width for the button
      width: 350, // Width of the button
      child: OutlinedButton( // Outlined button for menu options
        style: _menuButtonStyle(), // Custom style for the menu button
        onPressed: () { // Action when the button is pressed
          Navigator.push( // Navigate to the specified route
            context,
            MaterialPageRoute(builder: (context) => route), // Create a route to the specified widget
          );
        },
        child: Text(
          label, // Text displayed on the button
          style: const TextStyle(fontSize: 18, color: Colors.white), // Style for the button text
        ),
      ),
    );
  }

  // Menu Button Style
  ButtonStyle _menuButtonStyle() {
    return OutlinedButton.styleFrom( // Create a style for the outlined button
      backgroundColor: const Color(0xFFFA8742), // Background color for the button
      foregroundColor: Colors.white, // Text color for the button
      side: const BorderSide(color: Color(0xFFFA8742)), // Border color for the button
      shape: RoundedRectangleBorder( // Shape of the button
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 15), // Padding for the button
    ).copyWith( // Additional customization for the button
      overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) { // Change color on press
        if (states.contains(WidgetState.pressed)) { // If the button is pressed
          return const Color(0xFFF26600); // Change overlay color
        }
        return null; // No overlay color if not pressed
      }),
    );
  }

  // Logout Button Style
  ButtonStyle _logoutButtonStyle() {
    return OutlinedButton.styleFrom( // Create a style for the logout button
      backgroundColor: Colors.white, // Background color for the button
      foregroundColor: const Color(0xFFFA8742), // Text color for the button
      side: const BorderSide(color: Color(0xFFFA8742)), // Border color for the button
      shape: RoundedRectangleBorder( // Shape of the button
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 15), // Padding for the button
    ).copyWith( // Additional customization for the button
      overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) { // Change color on press
        if (states.contains(WidgetState.pressed)) { // If the button is pressed
          return Colors.red.withOpacity(0.1); // Change overlay color
        }
        return null; // No overlay color if not pressed
      }),
    );
  }
}
