import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DegreeDetailView extends StatelessWidget {
  final String degreeTitle;
  const DegreeDetailView({super.key, required this.degreeTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(degreeTitle),
        backgroundColor: const Color(0xFFFA8742),
      ),
      body: Stack(
        children: [
          // 📷 Background Image
          Positioned.fill(child: Image.asset("assets/2.jpg", fit: BoxFit.cover)),
          SafeArea(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("degrees").doc(degreeTitle).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Degree details not found.", style: TextStyle(color: Colors.white)));
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(degreeTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(data['details'] ?? "No detailed information available.", textAlign: TextAlign.justify),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
