
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentGradesView extends StatefulWidget {
  const StudentGradesView({super.key}); // Constructor without title parameter

  @override
  State<StudentGradesView> createState() => _StudentGradesViewState();
}

class _StudentGradesViewState extends State<StudentGradesView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _gradesData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGradesData();
  }

  Future<void> _loadGradesData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('grades').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          _gradesData = snapshot.data();
          _isLoading = false;
        });
      } else {
        throw Exception("Grades data not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading grades: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grades"),
        backgroundColor: const Color(0xFFFA8742
),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gradesData == null
              ? const Center(child: Text("No grades data available"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Grades"),
                      const SizedBox(height: 10),
                      _buildGradesTable(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFA8742
),
      ),
    );
  }

  Widget _buildGradesTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Subject",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Grade",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ..._gradesData!.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(entry.key),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(entry.value.toString()),
              ),
            ],
          );
        }),
      ],
    );
  }
}