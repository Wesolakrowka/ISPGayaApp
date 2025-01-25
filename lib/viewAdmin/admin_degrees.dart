import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDegrees extends StatefulWidget {
  @override
  _AdminDegreesState createState() => _AdminDegreesState();
}

class _AdminDegreesState extends State<AdminDegrees> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _addDegreePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Degree"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Degree Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5, // Większe pole tekstowe
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _addDegree,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _addDegree() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      await _firestore.collection('degrees').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
      });

      _nameController.clear();
      _descriptionController.clear();
      Navigator.pop(context); // Zamknięcie pop-upa po dodaniu
    }
  }

  void _editDegree(String docId, String currentName, String currentDescription) {
    _nameController.text = currentName;
    _descriptionController.text = currentDescription;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Degree"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Degree Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5, // Większe pole tekstowe
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('degrees').doc(docId).update({
                'name': _nameController.text.trim(),
                'description': _descriptionController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteDegree(String docId) async {
    await _firestore.collection('degrees').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Manage Degrees"), backgroundColor: Color(0xFFFA8742)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('degrees').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var degrees = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: degrees.length + 1, // Dodajemy 1 na "Add Degree"
                  itemBuilder: (context, index) {
                    if (index == degrees.length) {
                      // 🔥 Ostatni element - "Add Degree"
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Colors.orange.shade100,
                        child: ListTile(
                          title: Text(
                            "➕ Add New Degree",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFA8742)),
                          ),
                          onTap: _addDegreePopup, // Otwiera pop-up
                        ),
                      );
                    }

                    var degree = degrees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(degree['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(degree['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _editDegree(degree.id, degree['name'], degree['description'])),
                            IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () => _deleteDegree(degree.id)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
