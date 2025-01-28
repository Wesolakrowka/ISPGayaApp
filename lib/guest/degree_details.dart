import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DegreeDetailView extends StatelessWidget {
  final String degreeTitle;
  final String collection;

  const DegreeDetailView({super.key, required this.degreeTitle, required this.collection});

  // ✅ Nowa funkcja pobierająca dane stopnia
  Future<DocumentSnapshot?> getDegreeDetails(String collection, String degreeTitle) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(collection)
        .where("name", isEqualTo: degreeTitle) // Szukamy po polu "name"
        .get();

    if (query.docs.isEmpty) {
      print("❌ Brak danych dla: $degreeTitle w kolekcji: $collection");
      return null;
    } else {
      print("✅ Pobieranie danych z kolekcji: $collection dla: $degreeTitle");
      return query.docs.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/2.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 🔙 Back Button & Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          degreeTitle,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot?>(
                    future: getDegreeDetails(collection, degreeTitle), // 🔹 Teraz funkcja istnieje
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            "Degree details not found.",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        );
                      }
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text("Course Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text(
                                  data['details'] ?? "No detailed information available.",
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 20),
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
          ),
        ],
      ),
    );
  }
}
