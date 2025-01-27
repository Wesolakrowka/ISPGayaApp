import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserEdit extends StatefulWidget {
  const AdminUserEdit({super.key});

  @override
  _AdminUserEditState createState() => _AdminUserEditState();
}

class _AdminUserEditState extends State<AdminUserEdit> {
  final TextEditingController _userIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? selectedCourse;

  void fetchUserData() async {
    setState(() => isLoading = true);
    String userSearchId = _userIdController.text.trim();

    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: userSearchId)
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
    QuerySnapshot userQuery =
        await _firestore.collection('users').where('id', isEqualTo: userId).get();

    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first.id;
    } else {
      throw Exception("User not found in Firestore");
    }
  }

  void _addCourseToUser(String courseId) async {
    if (userData == null) return;

    String userDocId = await _getFirestoreDocumentId(userData!['id']);
    String userRole = userData!["role"];

    List<dynamic> userCourses =
        List<String>.from(userData![userRole == "prof" ? "courses" : "enrolledCourses"] ?? []);

    if (!userCourses.contains(courseId)) {
      userCourses.add(courseId);
      userData![userRole == "prof" ? "courses" : "enrolledCourses"] = userCourses;

      await _firestore.collection('users').doc(userDocId).update({
        userRole == "prof" ? "courses" : "enrolledCourses": userCourses,
      });

      DocumentReference courseRef = _firestore.collection('courses').doc(courseId);
      DocumentSnapshot courseSnapshot = await courseRef.get();

      if (courseSnapshot.exists) {
        if (userRole == "student") {
          List<dynamic> students = List<String>.from(courseSnapshot["students"] ?? []);
          if (!students.contains(userDocId)) {
            students.add(userDocId);
            await courseRef.update({"students": students});
          }
        } else if (userRole == "prof") {
          await courseRef.update({"professorId": userDocId});
        }
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Course added successfully!")),
      );
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
                            _buildInfoRow("User ID:", userData!['id'] ?? "N/A"),
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
    String fieldKey = isProfessor ? "courses" : "enrolledCourses";

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
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('courses').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              var courses = snapshot.data!.docs;

              return DropdownButton<String>(
                value: selectedCourse,
                hint: Text("Select a course"),
                isExpanded: true,
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text(course["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCourse = value);
                  _addCourseToUser(value!);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
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