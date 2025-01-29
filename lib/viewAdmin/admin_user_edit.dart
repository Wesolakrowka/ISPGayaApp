import 'package:flutter/material.dart'; // Importing Flutter's material design library for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user authentication

// AdminUserEdit is a StatefulWidget that allows an admin to edit user information
class AdminUserEdit extends StatefulWidget {
  const AdminUserEdit({super.key}); // Constructor for AdminUserEdit

  @override
  _AdminUserEditState createState() => _AdminUserEditState(); // Creating the state for AdminUserEdit
}

// _AdminUserEditState is the state class for AdminUserEdit
class _AdminUserEditState extends State<AdminUserEdit> {
  final TextEditingController _userIdController = TextEditingController(); // Controller for the user ID input field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth to manage user authentication

  Map<String, dynamic>? userData; // Variable to store fetched user data
  bool isLoading = false; // Flag to indicate loading state
  String? selectedCourse; // Variable to store the selected course

  // Function to fetch user data based on the user ID entered
  void fetchUserData() async {
    setState(() => isLoading = true); // Set loading state to true
    String userSearchId = _userIdController.text.trim(); // Get the trimmed user ID from the input field

    try {
      // Query Firestore for the user with the specified ID
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: userSearchId)
          .get();

      // Check if any user documents were found
      if (userQuery.docs.isNotEmpty) {
        setState(() {
          userData = userQuery.docs.first.data() as Map<String, dynamic>; // Store the user data
        });
      } else {
        setState(() => userData = null); // No user found, set userData to null
        // Show a snackbar message indicating the user was not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ User with ID $userSearchId not found.")),
        );
      }
    } catch (e) {
      // Show a snackbar message indicating an error occurred while fetching user data
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error fetching user: $e")));
    }

    setState(() => isLoading = false); // Set loading state to false
  }

  // Function to update the user data in Firestore
  void updateUser() async {
    if (userData == null) return; // If no user data, exit the function

    try {
      // Get the Firestore document ID for the user
      String userDocumentId = await _getFirestoreDocumentId(userData!['id']);

      // Update the user document in Firestore with the new data
      await _firestore.collection('users').doc(userDocumentId).update(userData!);
      // Show a snackbar message indicating the update was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ User data updated successfully!")),
      );
    } catch (e) {
      // Show a snackbar message indicating an error occurred while updating user data
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error updating user: $e")));
    }
  }

  // Function to reset the user's password
  void resetPassword() async {
    if (userData?['email'] == null) return; // If no email, exit the function

    try {
      // Send a password reset email to the user
      await _auth.sendPasswordResetEmail(email: userData!['email']);
      // Show a snackbar message indicating the email was sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📧 Password reset email sent!")),
      );
    } catch (e) {
      // Show a snackbar message indicating an error occurred while resetting the password
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error resetting password: $e")));
    }
  }

  // Function to get the Firestore document ID for a user based on their user ID
  Future<String> _getFirestoreDocumentId(String userId) async {
    // Query Firestore for the user with the specified ID
    QuerySnapshot userQuery =
        await _firestore.collection('users').where('id', isEqualTo: userId).get();

    // Check if any user documents were found
    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.id; // Return the document ID of the first user found
    } else {
      throw Exception("User not found in Firestore"); // Throw an exception if no user was found
    }
  }

  // Function to add a course to the user's list of courses
  void _addCourseToUser(String courseId) async {
    if (userData == null) return; // If no user data, exit the function

    // Get the Firestore document ID for the user
    String userDocId = await _getFirestoreDocumentId(userData!['id']);
    String userRole = userData!["role"]; // Get the user's role (student or professor)

    // Get the list of courses the user is enrolled in or teaching
    List<dynamic> userCourses =
        List<String>.from(userData![userRole == "prof" ? "courses" : "enrolledCourses"] ?? []);

    // Check if the course is already in the user's list
    if (!userCourses.contains(courseId)) {
      userCourses.add(courseId); // Add the course to the list
      userData![userRole == "prof" ? "courses" : "enrolledCourses"] = userCourses; // Update the user data

      // Update the user's document in Firestore with the new list of courses
      await _firestore.collection('users').doc(userDocId).update({
        userRole == "prof" ? "courses" : "enrolledCourses": userCourses,
      });

      // Get a reference to the course document in Firestore
      DocumentReference courseRef = _firestore.collection('courses').doc(courseId);
      DocumentSnapshot courseSnapshot = await courseRef.get(); // Fetch the course document

      // Check if the course document exists
      if (courseSnapshot.exists) {
        // If the user is a student, add them to the course's student list
        if (userRole == "student") {
          List<dynamic> students = List<String>.from(courseSnapshot["students"] ?? []);
          if (!students.contains(userDocId)) {
            students.add(userDocId); // Add the user to the students list
            await courseRef.update({"students": students}); // Update the course document
          }
        } else if (userRole == "prof") {
          // If the user is a professor, set their ID as the course's professor
          await courseRef.update({"professorId": userDocId});
        }
      }

      setState(() {}); // Trigger a rebuild of the widget
      // Show a snackbar message indicating the course was added successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Course added successfully!")),
      );
    }
  }

  // Build method to create the UI for the AdminUserEdit widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Edit User"), // Title of the app bar
        backgroundColor: Color(0xFFFA8742), // Background color of the app bar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around the body content
        child: Column(
          children: [
            // TextField for entering the user ID
            TextField(
              controller: _userIdController, // Controller for the input field
              decoration: InputDecoration(
                labelText: "🔎 Enter User ID", // Label for the input field
                suffixIcon:
                    IconButton(icon: Icon(Icons.search), onPressed: fetchUserData), // Search button
              ),
            ),
            SizedBox(height: 20), // Space between the input field and the next widget
            isLoading // Check if data is loading
                ? CircularProgressIndicator() // Show loading indicator
                : userData != null // Check if user data is available
                    ? Expanded(
                        child: ListView(
                          children: [
                            _buildInfoRow("User ID:", userData!['id'] ?? "N/A"), // Display user ID
                            buildEditableField("Full Name", "name"), // Editable field for full name
                            buildEditableField("Email", "email"), // Editable field for email
                            buildEditableField("Address", "address"), // Editable field for address
                            buildEditableField("City", "city"), // Editable field for city
                            buildEditableField("Country", "country"), // Editable field for country
                            buildEditableField("Phone", "contact"), // Editable field for phone
                            buildEditableField("Postal Code", "PostalCode"), // Editable field for postal code
                            buildEditableField("Date of Birth", "dateOfBirth"), // Editable field for date of birth
                            buildEditableField("Nationality", "nationality"), // Editable field for nationality
                            buildCoursesField(), // Field for managing courses
                            SizedBox(height: 20), // Space before the buttons
                            ElevatedButton(
                                onPressed: updateUser, // Button to save changes
                                child: Text("💾 Save Changes")),
                            ElevatedButton(
                              onPressed: resetPassword, // Button to reset password
                              child: Text("🔑 Reset Password"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red), // Red background for reset button
                            ),
                          ],
                        ),
                      )
                    : Container(), // Empty container if no user data is available
          ],
        ),
      ),
    );
  }

  // Function to build an editable text field
  Widget buildEditableField(String label, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5), // Vertical padding for the field
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()), // Input decoration
        controller: TextEditingController(text: userData?[key] ?? ''), // Set initial text from user data
        onChanged: (value) => userData?[key] = value, // Update user data on change
      ),
    );
  }

  // Function to build the courses field for adding/removing courses
  Widget buildCoursesField() {
    bool isProfessor = userData?["role"] == "prof"; // Check if the user is a professor
    String fieldKey = isProfessor ? "courses" : "enrolledCourses"; // Determine the field key based on role

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5), // Vertical padding for the field
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          // Display the appropriate title based on user role
          Text(isProfessor ? "📚 Teaching Courses" : "📚 Enrolled Courses",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            children: (userData?[fieldKey] as List<dynamic>? ?? []).map((course) {
              return Chip(
                label: Text(course), // Display the course name
                deleteIcon: Icon(Icons.close), // Icon to delete the course
                onDeleted: () {
                  setState(() {
                    (userData?[fieldKey] as List<dynamic>).remove(course); // Remove course from user data
                  });
                },
              );
            }).toList(),
          ),
          // StreamBuilder to listen for changes in the courses collection
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('courses').snapshots(), // Stream of course documents
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator(); // Show loading indicator if no data
              var courses = snapshot.data!.docs; // Get the list of courses

              return DropdownButton<String>(
                value: selectedCourse, // Currently selected course
                hint: Text("Select a course"), // Hint text for the dropdown
                isExpanded: true, // Expand the dropdown to fill available space
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id, // Course ID as the value
                    child: Text(course["name"]), // Display course name
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCourse = value); // Update selected course
                  _addCourseToUser(value!); // Add the selected course to the user
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Function to build an info row displaying a label and value
Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // Vertical padding for the row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between label and value
        children: [
          Text(
            label, // Display the label
            style: const TextStyle(
              fontSize: 16, // Font size for the label
              fontWeight: FontWeight.w600, // Bold font weight for the label
              color: Colors.grey, // Grey color for the label
            ),
          ),
          Flexible(
            child: Text(
              value, // Display the value
              textAlign: TextAlign.right, // Align text to the right
              style: const TextStyle(
                fontSize: 16, // Font size for the value
                fontWeight: FontWeight.w400, // Normal font weight for the value
                color: Colors.black, // Black color for the value
              ),
            ),
          ),
        ],
      ),
    );
}