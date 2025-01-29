import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database operations

// AdminDegrees is a StatefulWidget that allows the admin to manage degrees, CTESP, and masters
class AdminDegrees extends StatefulWidget {
  const AdminDegrees({super.key}); // Constructor for AdminDegrees

  @override
  _AdminDegreesState createState() => _AdminDegreesState(); // Creating the state for AdminDegrees
}

// _AdminDegreesState is the state class for AdminDegrees
class _AdminDegreesState extends State<AdminDegrees> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller for managing tab navigation
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore for database access
  final TextEditingController _nameController = TextEditingController(); // Controller for the name input field
  final TextEditingController _descriptionController = TextEditingController(); // Controller for the description input field
  final TextEditingController _detailsController = TextEditingController(); // Controller for the details input field
  String _currentCollection = 'degrees'; // Variable to track the currently selected collection (default is 'degrees')

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    _tabController = TabController(length: 3, vsync: this); // Initializing the TabController with 3 tabs
    _tabController.addListener(() { // Adding a listener to update the current collection when the tab changes
      setState(() {
        _currentCollection = ['degrees', 'ctesp', 'masters'][_tabController.index]; // Update the current collection based on the selected tab
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Disposing the TabController to free up resources
    super.dispose(); // Calling the superclass's dispose
  }

  // Function to show the Add/Edit dialog
  void _showPopup({String? docId, String? currentName, String? currentDescription, String? currentDetails}) {
    // Setting the text fields with current values or empty strings
    _nameController.text = currentName ?? ""; 
    _descriptionController.text = currentDescription ?? ""; 
    _detailsController.text = currentDetails ?? ""; // Load existing details

    // Displaying a dialog for adding or editing an entry
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Add New $_currentCollection" : "Edit $_currentCollection"), // Title based on whether it's a new entry or editing
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Allowing the column to take minimum space
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")), // Input field for name
              const SizedBox(height: 10), // Space between input fields
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3), // Input field for description
              const SizedBox(height: 10), // Space between input fields
              TextField(controller: _detailsController, decoration: const InputDecoration(labelText: "Detailed Information"), maxLines: 5), // Input field for detailed information
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), // Cancel button to close the dialog
          ElevatedButton(
            onPressed: () async {
              // Checking if all fields are filled before saving
              if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _detailsController.text.isNotEmpty) {
                if (docId == null) { // If no document ID, add a new entry
                  await _firestore.collection(_currentCollection).add({
                    'name': _nameController.text.trim(), // Saving name
                    'description': _descriptionController.text.trim(), // Saving description
                    'details': _detailsController.text.trim(), // Saving details
                  });
                } else { // If document ID exists, update the existing entry
                  await _firestore.collection(_currentCollection).doc(docId).update({
                    'name': _nameController.text.trim(), // Updating name
                    'description': _descriptionController.text.trim(), // Updating description
                    'details': _detailsController.text.trim(), // Updating details
                  });
                }
                // Clearing the text fields after saving
                _nameController.clear();
                _descriptionController.clear();
                _detailsController.clear();
                Navigator.pop(context); // Closing the dialog
              }
            },
            child: const Text("Save"), // Save button to confirm changes
          ),
        ],
      ),
    );
  }

  // Function to delete an entry
  void _deleteEntry(String docId) async {
    await _firestore.collection(_currentCollection).doc(docId).delete(); // Deleting the specified document from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"), // Title of the app bar
        backgroundColor: const Color(0xFFFA8742), // Background color of the app bar
        bottom: TabBar(
          controller: _tabController, // Controller for the tab bar
          labelColor: Colors.white, // Color of the selected tab label
          indicatorColor: Colors.white, // Color of the tab indicator
          tabs: const [
            Tab(text: "Degrees"), // Tab for Degrees
            Tab(text: "CTeSP"), // Tab for CTeSP
            Tab(text: "Masters"), // Tab for Masters
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset("assets/2.jpg", fit: BoxFit.cover)), // Background image for the entire screen

          // Main Content
          SafeArea(
            child: TabBarView(
              controller: _tabController, // Controller for the tab view
              children: [
                _buildList("degrees"), // Building the list for Degrees
                _buildList("ctesp"), // Building the list for CTeSP
                _buildList("masters"), // Building the list for Masters
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to fetch and display the list of items
  Widget _buildList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(), // Listening to real-time updates from Firestore
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); // Loading indicator while data is being fetched
        var items = snapshot.data!.docs; // Getting the list of documents

        return ListView.builder(
          itemCount: items.length + 1, // Adding one for the "Add New" button
          itemBuilder: (context, index) {
            if (index == items.length) { // If it's the last item, show the "Add New" button
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Margin for the card
                color: Colors.orange.shade100, // Background color for the card
                child: ListTile(
                  title: Text(
                    "➕ Add New ${collection.capitalize()}", // Title for adding a new item
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFA8742)), // Styling for the title
                  ),
                  onTap: () => _showPopup(), // Show the popup for adding a new item
                ),
              );
            }

            var item = items[index]; // Getting the current item
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Margin for the card
              child: ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)), // Displaying the name of the item
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligning the subtitle to the start
                  children: [
                    Text(item['description']), // Displaying the description of the item
                    const SizedBox(height: 5), // Space between description and details
                    Text("Details: ${item['details'] ?? 'No details available.'}", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)), // Displaying details or a placeholder if none are available
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Minimizing the size of the row
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit), // Edit icon button
                      onPressed: () => _showPopup(
                        docId: item.id, // Passing the document ID for editing
                        currentName: item['name'], // Current name for the text field
                        currentDescription: item['description'], // Current description for the text field
                        currentDetails: item['details'], // Current details for the text field
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () => _deleteEntry(item.id)), // Delete icon button
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

// Extension to capitalize the first letter of a word
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}"; // Capitalizing the first letter of the string
  }
}
