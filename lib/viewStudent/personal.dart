import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          _userData = snapshot.data();
          _isLoading = false;
        });
      } else {
        throw Exception("User profile not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
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
        title: const Text("Personal Data"),
        backgroundColor: const Color(0xFFFA8742
),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("No user data available"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sekcja zdjęcia
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            _userData!['profilePictureUrl'] ?? 
                                "https://via.placeholder.com/150", // Placeholder jeśli brak zdjęcia
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sekcja General Information
                      _buildSectionTitle("General Information"),
                      const SizedBox(height: 10),
                      _buildInfoRow("ID:", _userData!['id'] ?? "N/A"), // 🔥 Dodane ID użytkownika
                      _buildInfoRow("Complete Name:", _userData!['name'] ?? "N/A"),
                      _buildInfoRow("Nationality:", _userData!['nationality'] ?? "N/A"),
                      _buildInfoRow("Status:", _userData!['Status'] ?? "N/A"),
                      _buildInfoRow("Date of Birth:", _userData!['dateOfBirth'] ?? "N/A"),
                      _buildInfoRow("Official E-mail:", _userData!['email'] ?? "N/A"),
                      _buildInfoRow("Picture Status:", _userData!['pictureStatus'] ?? "N/A"),
                      const SizedBox(height: 20),

                      // Sekcja Official Address
                      _buildSectionTitle("Official Address"),
                      const SizedBox(height: 10),
                      _buildInfoRow("Address:", _userData!['address'] ?? "N/A"),
                      _buildInfoRow("Town/City:", _userData!['city'] ?? "N/A"),
                      _buildInfoRow("Postal Code:", _userData!['PostalCode'] ?? "N/A"),
                      _buildInfoRow("Country:", _userData!['country'] ?? "N/A"),
                      const SizedBox(height: 20),

                      // Sekcja Official Contact
                      _buildSectionTitle("Official Contact"),
                      const SizedBox(height: 10),
                      _buildInfoRow("Type:", _userData!['contactType'] ?? "N/A"),
                      _buildInfoRow("Contact:", _userData!['contact'] ?? "N/A"),
                    ],
                  ),
                ),
    );
  }

  // Nagłówki sekcji
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

  // Wiersze informacji (etykieta + wartość)
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
