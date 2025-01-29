import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database access

// PersonalData is a StatefulWidget that manages the personal data view of the user
class PersonalData extends StatefulWidget {
  const PersonalData({super.key}); // Constructor for PersonalData

  @override
  State<PersonalData> createState() => _PersonalDataState(); // Creating the state for PersonalData
}

// _PersonalDataState is the state class for PersonalData
class _PersonalDataState extends State<PersonalData> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth to manage user authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database

  Map<String, dynamic>? _userData; // Variable to hold user data retrieved from Firestore
  bool _isLoading = true; // Loading state to show a loading indicator while fetching data

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    _loadUserData(); // Initiating the user data loading process
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser; // Getting the currently logged-in user
      if (user == null) {
        throw Exception("User not logged in"); // Throwing an exception if no user is logged in
      }

      // Fetching the user document from Firestore using the user's UID
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) { // Checking if the user document exists
        setState(() {
          _userData = snapshot.data(); // Storing the user data in the state
          _isLoading = false; // Setting loading state to false
        });
      } else {
        throw Exception("User profile not found"); // Throwing an exception if the user profile is not found
      }
    } catch (e) {
      // Displaying an error message if an exception occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
      setState(() {
        _isLoading = false; // Setting loading state to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Data"), // Title of the AppBar
        backgroundColor: const Color(0xFFFA8742), // Background color of the AppBar
      ),
      body: _isLoading // Conditional rendering based on loading state
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator if data is loading
          : _userData == null // Check if user data is null
              ? const Center(child: Text("No user data available")) // Show message if no user data is available
              : SingleChildScrollView( // Scrollable view for user data
                  padding: const EdgeInsets.all(16.0), // Padding for the scrollable view
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligning children to the start
                    children: [
                      // Section for user profile picture
                      Center(
                        child: CircleAvatar(
                          radius: 60, // Radius of the circular avatar
                          backgroundImage: NetworkImage(
                            _userData!['profilePictureUrl'] ?? 
                                "https://via.placeholder.com/150", // Placeholder if no profile picture URL is available
                          ),
                          backgroundColor: Colors.grey[300], // Background color for the avatar
                        ),
                      ),
                      const SizedBox(height: 20), // Spacing between elements

                      // Section for General Information
                      _buildSectionTitle("General Information"), // Building section title
                      const SizedBox(height: 10), // Spacing between elements
                      _buildInfoRow("ID:", _userData!['id'] ?? "N/A"), // Displaying user ID
                      _buildInfoRow("Complete Name:", _userData!['name'] ?? "N/A"), // Displaying user name
                      _buildInfoRow("Nationality:", _userData!['nationality'] ?? "N/A"), // Displaying user nationality
                      _buildInfoRow("Status:", _userData!['Status'] ?? "N/A"), // Displaying user status
                      _buildInfoRow("Date of Birth:", _userData!['dateOfBirth'] ?? "N/A"), // Displaying user date of birth
                      _buildInfoRow("Official E-mail:", _userData!['email'] ?? "N/A"), // Displaying user email
                      _buildInfoRow("Picture Status:", _userData!['pictureStatus'] ?? "N/A"), // Displaying picture status
                      const SizedBox(height: 20), // Spacing between elements

                      // Section for Official Address
                      _buildSectionTitle("Official Address"), // Building section title
                      const SizedBox(height: 10), // Spacing between elements
                      _buildInfoRow("Address:", _userData!['address'] ?? "N/A"), // Displaying user address
                      _buildInfoRow("Town/City:", _userData!['city'] ?? "N/A"), // Displaying user city
                      _buildInfoRow("Postal Code:", _userData!['PostalCode'] ?? "N/A"), // Displaying user postal code
                      _buildInfoRow("Country:", _userData!['country'] ?? "N/A"), // Displaying user country
                      const SizedBox(height: 20), // Spacing between elements

                      // Section for Official Contact
                      _buildSectionTitle("Official Contact"), // Building section title
                      const SizedBox(height: 10), // Spacing between elements
                      _buildInfoRow("Type:", _userData!['contactType'] ?? "N/A"), // Displaying contact type
                      _buildInfoRow("Contact:", _userData!['contact'] ?? "N/A"), // Displaying contact information
                    ],
                  ),
                ),
    );
  }

  // Function to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, // Font size for the section title
        fontWeight: FontWeight.bold, // Bold font weight for the title
        color: Color(0xFFFA8742), // Color for the section title
      ),
    );
  }

  // Function to build information rows (label + value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // Vertical padding for the row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between label and value
        children: [
          Text(
            label, // Label text
            style: const TextStyle(
              fontSize: 16, // Font size for the label
              fontWeight: FontWeight.w600, // Semi-bold font weight for the label
              color: Colors.grey, // Color for the label
            ),
          ),
          Flexible(
            child: Text(
              value, // Value text
              textAlign: TextAlign.right, // Aligning text to the right
              style: const TextStyle(
                fontSize: 16, // Font size for the value
                fontWeight: FontWeight.w400, // Normal font weight for the value
                color: Colors.black, // Color for the value
              ),
            ),
          ),
        ],
      ),
    );
  }
}