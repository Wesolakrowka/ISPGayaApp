import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

void populateFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Random random = Random();

  // Generate a random 10-digit user ID
  String generateUserId() {
    return (1000000000 + random.nextInt(900000000)).toString();
  }

  // Sample Professors
  List<Map<String, dynamic>> professors = [
    {"name": "Dr. John Smith", "email": "john.smith@ispgaya.pt", "role": "prof", "courses": []},
    {"name": "Dr. Emily Clarke", "email": "emily.clarke@ispgaya.pt", "role": "prof", "courses": []}
  ];

  // Sample Students
  List<Map<String, dynamic>> students = [
    {"name": "Alice Johnson", "email": "alice.johnson@ispgaya.pt", "role": "student", "enrolledCourses": []},
    {"name": "Bob Williams", "email": "bob.williams@ispgaya.pt", "role": "student", "enrolledCourses": []}
  ];

  // Sample Courses
  List<Map<String, dynamic>> courses = [
    {"name": "Computer Networks", "id": "", "students": [], "schedule": {}},
    {"name": "Digital Marketing", "id": "", "students": [], "schedule": {}}
  ];

  // 🔹 Add Professors with a 10-digit userId
  for (var prof in professors) {
    prof["id"] = generateUserId();
    DocumentReference docRef = await firestore.collection("users").add(prof);
    prof["id"] = docRef.id;
  }

  // 🔹 Add Students with a 10-digit userId
  for (var student in students) {
    student["id"] = generateUserId();
    DocumentReference docRef = await firestore.collection("users").add(student);
    student["id"] = docRef.id;
  }

  // 🔹 Assign Professors to Courses
  for (int i = 0; i < courses.length; i++) {
    courses[i]["id"] = professors[i % professors.length]["id"];
    DocumentReference docRef = await firestore.collection("courses").add(courses[i]);
    courses[i]["id"] = docRef.id;
    professors[i % professors.length]["courses"].add(docRef.id);
  }

  // 🔹 Update Professors with Assigned Courses
  for (var prof in professors) {
    await firestore.collection("users").doc(prof["profid"]).update({"courses": prof["courses"]});
  }

  // 🔹 Enroll Students in Courses
  for (int i = 0; i < students.length; i++) {
    students[i]["enrolledCourses"].add(courses[i % courses.length]["id"]);
    await firestore.collection("users").doc(students[i]["id"]).update({"enrolledCourses": students[i]["enrolledCourses"]});
    await firestore.collection("courses").doc(courses[i % courses.length]["id"]).update({
      "students": FieldValue.arrayUnion([students[i]["id"]])
    });
  }

  print("🔥 Firestore Populated Successfully with 10-digit User IDs!");
}
