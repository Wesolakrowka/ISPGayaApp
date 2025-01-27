import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDegrees extends StatefulWidget {
  const AdminDegrees({super.key});

  @override
  _AdminDegreesState createState() => _AdminDegreesState();
}

class _AdminDegreesState extends State<AdminDegrees> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController(); // New field for details
  String _currentCollection = 'degrees'; // Default tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentCollection = ['degrees', 'ctesp', 'masters'][_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 📌 Function to show the Add/Edit dialog
  void _showPopup({String? docId, String? currentName, String? currentDescription, String? currentDetails}) {
    _nameController.text = currentName ?? "";
    _descriptionController.text = currentDescription ?? "";
    _detailsController.text = currentDetails ?? ""; // Load existing details

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Add New $_currentCollection" : "Edit $_currentCollection"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 10),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
              const SizedBox(height: 10),
              TextField(controller: _detailsController, decoration: const InputDecoration(labelText: "Detailed Information"), maxLines: 5), // New details field
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _detailsController.text.isNotEmpty) {
                if (docId == null) {
                  await _firestore.collection(_currentCollection).add({
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'details': _detailsController.text.trim(), // Save details field
                  });
                } else {
                  await _firestore.collection(_currentCollection).doc(docId).update({
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'details': _detailsController.text.trim(), // Update details field
                  });
                }
                _nameController.clear();
                _descriptionController.clear();
                _detailsController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 📌 Function to delete an entry
  void _deleteEntry(String docId) async {
    await _firestore.collection(_currentCollection).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFFFA8742),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Degrees"),
            Tab(text: "CTeSP"),
            Tab(text: "Masters"),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 📷 Background Image
          Positioned.fill(child: Image.asset("assets/2.jpg", fit: BoxFit.cover)),

          // 📋 Main Content
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList("degrees"),
                _buildList("ctesp"),
                _buildList("masters"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Function to fetch and display the list of items
  Widget _buildList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var items = snapshot.data!.docs;

        return ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              // 🔥 Last Item - "Add New"
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.orange.shade100,
                child: ListTile(
                  title: Text(
                    "➕ Add New ${collection.capitalize()}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFA8742)),
                  ),
                  onTap: () => _showPopup(),
                ),
              );
            }

            var item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['description']),
                    const SizedBox(height: 5),
                    Text("Details: ${item['details'] ?? 'No details available.'}", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)), // Show details
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showPopup(
                        docId: item.id,
                        currentName: item['name'],
                        currentDescription: item['description'],
                        currentDetails: item['details'], // Pass details for editing
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () => _deleteEntry(item.id)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 🔹 Extension to capitalize the first letter of a word
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
