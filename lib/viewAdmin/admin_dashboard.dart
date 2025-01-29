import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user authentication
import 'package:applicationispgaya/login_view.dart'; // Importing the login view for user authentication
import 'package:applicationispgaya/messages/contacts_view.dart'; // Importing the contacts view for messaging functionality
import 'package:applicationispgaya/viewAdmin/admin_class_management.dart'; // Importing the class management view for admin
import 'package:applicationispgaya/viewStudent/schedule.dart'; // Importing the schedule view for displaying user schedules
import 'package:applicationispgaya/viewAdmin/admin_user_edit.dart'; // Importing the user edit view for admin
import 'package:applicationispgaya/viewAdmin/admin_degrees.dart'; // Importing the degrees management view for admin

// AdminDashboard is a StatelessWidget that represents the admin's dashboard
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key}); // Constructor for AdminDashboard

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold provides a structure for the visual interface
      body: Stack( // Stack allows for overlapping widgets
        children: [
          // Background image for the entire page
          Positioned.fill( // Fills the available space with the background image
            child: Image.asset(
              "assets/2.jpg", // Path to the background image in assets
              fit: BoxFit.cover, // Ensures the image covers the entire area
            ),
          ),

          // Main content area
          SafeArea( // Ensures that the content is not obscured by system UI
            child: Column( // Column arranges its children vertically
              children: [
                // Logo and title section
                Container(
                  color: Colors.transparent, // Transparent background for the container
                  padding: const EdgeInsets.symmetric(vertical: 20), // Vertical padding
                  child: Column( // Nested column for logo and title
                    children: [
                      Text(
                        'ISPGAYA', // Title text
                        style: TextStyle(
                          color: const Color(0xFFFA8742), // Color for the title
                          fontSize: MediaQuery.of(context).size.width * 0.1, // Responsive font size
                          fontWeight: FontWeight.bold, // Bold font weight
                        ),
                      ),
                      const SizedBox(height: 5), // Space between title and subtitle
                      Text(
                        'Instituto Superior Politécnico', // Subtitle text
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), // Semi-transparent white color
                          fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Space between logo and buttons

                // Button section
                Expanded( // Expands to fill available space
                  child: SingleChildScrollView( // Allows scrolling if content overflows
                    child: Column( // Column for buttons
                      children: [
                        _buildMenuButton(context, label: 'Schedule', route: Schedule()), // Button for Schedule
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Class Management', route: AdminClassManagement()), // Button for Class Management
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Messages', route: ContactsView()), // Button for Messages
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Manage Users', route: AdminUserEdit()), // Button for Manage Users
                        const SizedBox(height: 20), // Space between buttons

                        _buildMenuButton(context, label: 'Manage Degrees', route: AdminDegrees()), // Button for Manage Degrees
                        const SizedBox(height: 20), // Space between buttons

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.all(20), // Padding around the button
                          child: SizedBox(
                            width: double.infinity, // Button takes full width
                            child: OutlinedButton( // Outlined button for logout
                              style: _logoutButtonStyle(), // Style for the logout button
                              onPressed: () async { // Function to execute on button press
                                await FirebaseAuth.instance.signOut(); // Sign out the user
                                Navigator.pushAndRemoveUntil( // Navigate to login view
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(title: 'Login'), // Login view
                                  ),
                                  (route) => false, // Remove all previous routes
                                );
                              },
                              child: const Text( // Text displayed on the button
                                'Logout',
                                style: TextStyle(fontSize: 18, color: Color(0xFFFA8742)), // Text style
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact section (pinned at the bottom)
                Container(
                  width: double.infinity, // Full width container
                  color: Colors.black.withOpacity(0.6), // Semi-transparent black background
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Padding for the container
                  child: const Column( // Column for contact information
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                    children: [
                      Text(
                        'Contacts:', // Header for contact information
                        style: TextStyle(
                          color: Color(0xFFFA8742), // Color for the header
                          fontWeight: FontWeight.bold, // Bold font weight
                          fontSize: 18, // Font size for the header
                        ),
                      ),
                      SizedBox(height: 5), // Space below the header
                      Text(
                        'Av. dos Descobrimentos, 333\n' // Address line 1
                        '4400-103 Santa Marinha - V.N.Gaia\n' // Address line 2
                        '(+351) 223 745 730\n' // Phone number
                        'info@ispgaya.pt', // Email address
                        style: TextStyle(fontSize: 12, color: Colors.white), // Style for contact details
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

  // Method to generate menu buttons
  Widget _buildMenuButton(BuildContext context, {required String label, required Widget route}) {
    return SizedBox(
      width: 350, // Fixed width for the button
      child: OutlinedButton( // Outlined button for menu options
        style: _buttonStyle(), // Style for the button
        onPressed: () { // Function to execute on button press
          Navigator.push( // Navigate to the specified route
            context,
            MaterialPageRoute(builder: (context) => route), // Create a route to the specified widget
          );
        },
        child: Text( // Text displayed on the button
          label, // Button label
          style: const TextStyle(fontSize: 18, color: Colors.white), // Text style
        ),
      ),
    );
  }

  // Style for menu buttons
  ButtonStyle _buttonStyle() {
    return OutlinedButton.styleFrom( // Create a style for the outlined button
      backgroundColor: const Color(0xFFFA8742), // Background color for the button
      foregroundColor: Colors.white, // Text color for the button
      side: const BorderSide(color: Color(0xFFFA8742)), // Border color for the button
      shape: RoundedRectangleBorder( // Shape of the button
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 15), // Padding for the button
    ).copyWith( // Additional customization for the button
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) { // Change overlay color when pressed
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFFF26600); // Color when button is pressed
          }
          return null; // Default overlay color
        },
      ),
    );
  }

  // Style for the Logout button
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
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) { // Change overlay color when pressed
          if (states.contains(WidgetState.pressed)) {
            return Colors.red.withOpacity(0.1); // Color when button is pressed
          }
          return null; // Default overlay color
        },
      ),
    );
  }
}