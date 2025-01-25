import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserEdit extends StatefulWidget {
  @override
  _AdminUserEditState createState() => _AdminUserEditState();
}

class _AdminUserEditState extends State<AdminUserEdit> {
  final TextEditingController _userIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData;
  bool isLoading = false;

  void fetchUserData() async {
    setState(() => isLoading = true);
    String userSearchId = _userIdController.text.trim();

    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: userSearchId) // 🔥 Search by Firestore 'id'
          .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          userData = userQuery.docs.first.data() as Map<String, dynamic>;
        });
      } else {
        setState(() => userData = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ User with ID $userSearchId not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error fetching user: $e")));
    }

    setState(() => isLoading = false);
  }

  void updateUser() async {
    if (userData == null) return;

    try {
      String userDocumentId = await _getFirestoreDocumentId(userData!['id']);

      await _firestore.collection('users').doc(userDocumentId).update(userData!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ User data updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error updating user: $e")));
    }
  }

  void resetPassword() async {
    if (userData?['email'] == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: userData!['email']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📧 Password reset email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error resetting password: $e")));
    }
  }

  Future<String> _getFirestoreDocumentId(String userId) async {
    // Get the Firestore document ID based on the stored "id" field
    QuerySnapshot userQuery =
        await _firestore.collection('users').where('id', isEqualTo: userId).get();

    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.id; // 🔥 Return Firestore document ID
    } else {
      throw Exception("User not found in Firestore");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin - Edit User"),
        backgroundColor: Color(0xFFFA8742),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: "🔎 Enter User ID",
                suffixIcon:
                    IconButton(icon: Icon(Icons.search), onPressed: fetchUserData),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : userData != null
                    ? Expanded(
                        child: ListView(
                          children: [
                            _buildInfoRow("User ID:", userData!['id'] ?? "N/A"), // 🔥 Displays Firestore 'id'
                            buildEditableField("Full Name", "name"),
                            buildEditableField("Email", "email"),
                            buildEditableField("Address", "address"),
                            buildEditableField("City", "city"),
                            buildEditableField("Country", "country"),
                            buildEditableField("Phone", "contact"),
                            buildEditableField("Postal Code", "PostalCode"),
                            buildEditableField("Date of Birth", "dateOfBirth"),
                            buildEditableField("Nationality", "nationality"),
                            buildCoursesField(),
                            SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: updateUser,
                                child: Text("💾 Save Changes")),
                            ElevatedButton(
                              onPressed: resetPassword,
                              child: Text("🔑 Reset Password"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField(String label, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        controller: TextEditingController(text: userData?[key] ?? ''),
        onChanged: (value) => userData?[key] = value,
      ),
    );
  }

  Widget buildCoursesField() {
    bool isProfessor = userData?["role"] == "prof";
    String fieldKey = isProfessor ? "courses" : "enrolledCourses"; // 🔥 Switches between "courses" & "enrolledCourses"

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isProfessor ? "📚 Teaching Courses" : "📚 Enrolled Courses",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            children: (userData?[fieldKey] as List<dynamic>? ?? []).map((course) {
              return Chip(
                label: Text(course),
                deleteIcon: Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    (userData?[fieldKey] as List<dynamic>).remove(course);
                  });
                },
              );
            }).toList(),
          ),
          TextField(
            decoration: InputDecoration(labelText: "➕ Add Course", suffixIcon: Icon(Icons.add)),
            onSubmitted: (value) {
              setState(() {
                (userData?[fieldKey] as List<dynamic>?)?.add(value);
              });
            },
          ),
        ],
      ),
    );
  }

  // Row to display user ID
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
