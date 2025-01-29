import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:applicationispgaya/guest/degrees_guest.dart'; // Importing the Degrees page for navigation
import 'package:applicationispgaya/guest/school_info_page.dart'; // Importing the School Information page for navigation
import 'package:applicationispgaya/login_view.dart'; // Importing the Login View for navigation back to login

// GuestHomeView is a StatelessWidget that represents the home view for guests
class GuestHomeView extends StatelessWidget {
  const GuestHomeView({super.key}); // Constructor for GuestHomeView

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold provides a structure for the visual interface
      body: Stack( // Stack allows for overlapping widgets
        children: [
          // Background Image
          Positioned.fill( // Fills the available space with the background image
            child: Image.asset("assets/1-1503_2.jpg", fit: BoxFit.cover), // Loading the background image
          ),
          SafeArea( // Ensures that the content is not obscured by system UI
            child: Column( // Column arranges its children vertically
              children: [
                // Title Section
                Container( // Container for the title section
                  padding: const EdgeInsets.symmetric(vertical: 20), // Vertical padding for the title
                  color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                  child: Center( // Center aligns the child widget
                    child: Text( // Text widget for the title
                      "Welcome to ISPGAYA", // Title text
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Text style
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Spacer with a height of 20

                // Introduction Section
                Padding( // Padding around the introduction section
                  padding: const EdgeInsets.all(16.0), // Padding of 16 on all sides
                  child: _buildSection( // Building a section with title and content
                    title: "About ISPGAYA", // Title for the section
                    content: "The Instituto Superior Politécnico de Gaya (ISPGAYA) was established in 1990 in Vila Nova de Gaia, Portugal. Our mission is to deliver high-quality higher education, fostering the development of well-rounded professionals equipped for the job market.", // Content for the section
                  ),
                ),

                // Navigation Buttons
                Expanded( // Expanded widget to fill available space
                  child: ListView( // ListView for scrolling through navigation buttons
                    children: [
                      _buildMenuButton(context, "Degrees", const DegreesPage()), // Button for navigating to Degrees page
                      _buildMenuButton(context, "School Information", const SchoolInfoPage()), // Button for navigating to School Information page
                    ],
                  ),
                ),

                // Back to Login Button
                Padding( // Padding around the back to login button
                  padding: const EdgeInsets.all(20), // Padding of 20 on all sides
                  child: SizedBox( // SizedBox to define the width of the button
                    width: double.infinity, // Button takes full width
                    child: OutlinedButton( // OutlinedButton for back navigation
                      style: OutlinedButton.styleFrom( // Styling the button
                        backgroundColor: Colors.white.withOpacity(0.9), // Semi-transparent white background
                        foregroundColor: Colors.black, // Black text color
                        side: const BorderSide(color: Color(0xFFFA8742)), // Border color
                        padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding for the button
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
                      ),
                      onPressed: () { // Action when button is pressed
                        Navigator.pushReplacement( // Navigating to the LoginView
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView(title: "Login")), // Creating a route to LoginView
                        );
                      },
                      child: const Text("← Back to Login", style: TextStyle(fontSize: 18)), // Button text
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

  // Styled Menu Buttons
  Widget _buildMenuButton(BuildContext context, String title, Widget page) { // Method to create styled menu buttons
    return Padding( // Padding around the button
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Horizontal and vertical padding
      child: ElevatedButton( // ElevatedButton for menu options
        style: ElevatedButton.styleFrom( // Styling the button
          backgroundColor: Colors.white.withOpacity(0.9), // Semi-transparent white background
          foregroundColor: Colors.black, // Black text color
          padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding for the button
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)), // Navigating to the specified page
        child: Text(title, style: const TextStyle(fontSize: 18)), // Button text
      ),
    );
  }

  // Styled Section Box
  Widget _buildSection({required String title, required String content}) { // Method to create a styled section box
    return Container( // Container for the section
      padding: const EdgeInsets.all(12), // Padding of 12 on all sides
      decoration: BoxDecoration( // Decoration for the container
        color: Colors.white.withOpacity(0.85), // Semi-transparent white background
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)], // Shadow effect
      ),
      child: Column( // Column to arrange title and content vertically
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Title text
          const SizedBox(height: 10), // Spacer with a height of 10
          Text(content, textAlign: TextAlign.justify), // Content text with justified alignment
        ],
      ),
    );
  }
}
