import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📷 Obraz tła na całą stronę
          Positioned.fill(
            child: Image.asset(
              "assets/1.jpg", // Ścieżka do obrazu w assets
              fit: BoxFit.cover,
            ),
          ),

          // 📋 Główna zawartość
          SafeArea(
            child: Column(
              children: [
                // 🟠 Nagłówek
                Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      "Welcome to ISPGAYA",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏫 Wprowadzenie
                          _buildSection(
                            title: "Welcome to Instituto Superior Politécnico Gaya (ISPGAYA)!",
                            content:
                                "ISPGAYA, established in 1990, is committed to delivering high-quality higher education focused on practical skills. Our mission is to prepare students for the job market by providing innovative learning experiences.",
                          ),
                          const SizedBox(height: 20),

                          // ℹ️ Informacje o szkole
                          _buildInfoCard(),

                          const SizedBox(height: 20),

                          // 🎓 Sekcja stopni
                          _buildTitle("Our Degrees"),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('degrees').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text("No degrees available at the moment.");
                              }

                              return ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  return _degreeTile(
                                    context,
                                    data['name'] ?? "Unknown Degree",
                                    data['description'] ?? "No description available.",
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
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

  // 🏛️ Stylizowana sekcja z tytułem i treścią
  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(content, textAlign: TextAlign.justify),
        ],
      ),
    );
  }

  // ℹ️ Stylizowana karta z informacjami o uczelni
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("📍 Address:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Av. dos Descobrimentos, 333, 4400-103 Santa Marinha - V.N. Gaia, Portugal"),
          SizedBox(height: 10),
          Text("📞 Contact:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("(+351) 223 745 730"),
          SizedBox(height: 10),
          Text("📧 Email:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("info@ispgaya.pt"),
          SizedBox(height: 10),
          Text("🌍 Website:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("https://ispgaya.pt/en"),
        ],
      ),
    );
  }

  // 📌 Nagłówek sekcji
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // 🎓 Karta z danym stopniem
  Widget _degreeTile(BuildContext context, String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFA8742)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DegreeDetailView(degreeTitle: title)),
          );
        },
      ),
    );
  }
}

// 📜 Ekran szczegółów stopnia
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
          // 📷 Tło dla strony
         
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('degrees').doc(degreeTitle).get(),
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
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
                    ],
                  ),
                  child: Text(
                    data['description'] ?? "No detailed information available.",
                    textAlign: TextAlign.justify,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
