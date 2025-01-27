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
          _buildDegreeList("ctesp"),
          _buildDegreeList("degrees"),
          _buildDegreeList("masters"),
        ],
      ),
    );
  }

  // 📌 Function to fetch and display the list of courses
  Widget _buildDegreeList(String category) {
    return Stack(
      children: [
        // 📷 Background Image
        Positioned.fill(child: Image.asset("assets/2.jpg", fit: BoxFit.cover)),

        SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(category).snapshots(),
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
                  return _degreeTile(context, data['name'] ?? "Unknown", data['description'] ?? "No description available.");
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // 📌 Degree List Tile
  Widget _degreeTile(BuildContext context, String title, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFA8742)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DegreeDetailView(degreeTitle: title))),
      ),
    );
  }
}
