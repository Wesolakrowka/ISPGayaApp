import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:applicationispgaya/guest/degree_details.dart';

class DegreesPage extends StatefulWidget {
  const DegreesPage({super.key});

  @override
  _DegreesPageState createState() => _DegreesPageState();
}

class _DegreesPageState extends State<DegreesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Degrees"),
        backgroundColor: const Color(0xFFFA8742),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "CTeSP"),
            Tab(text: "Degrees"),
            Tab(text: "Masters"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDegreeList("ctesp"),  // ✅ Dodano obsługę CTeSP
          _buildDegreeList("degrees"),
          _buildDegreeList("masters"), // ✅ Dodano obsługę Masters
        ],
      ),
    );
  }

  // 📌 Pobieranie listy programów dla danej kategorii
  Widget _buildDegreeList(String collectionName) {
    return Stack(
      children: [
        // 📷 Background Image
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No courses available at the moment.", style: TextStyle(color: Colors.white)),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = data['name'] ?? "Unknown";
                  String description = data['description'] ?? "No description available.";
                  return _degreeTile(context, name, description, collectionName);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // 📌 Degree List Tile (Poprawione!)
  Widget _degreeTile(BuildContext context, String title, String description, String collection) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFA8742)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DegreeDetailView(degreeTitle: title, collection: collection), // ✅ Teraz przekazujemy kolekcję
          ),
        ),
      ),
    );
  }
}
