import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database access

class DegreeDetailView extends StatelessWidget {
  final String degreeTitle; // Title of the degree
  final String collection; // Collection name in Firestore

  // Constructor for DegreeDetailView, requires degreeTitle and collection as parameters
  const DegreeDetailView({super.key, required this.degreeTitle, required this.collection});

  // Function to fetch degree details from Firestore
  Future<DocumentSnapshot?> getDegreeDetails(String collection, String degreeTitle) async {
    // Query Firestore to find documents in the specified collection where the name matches the degreeTitle
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(collection)
        .where("name", isEqualTo: degreeTitle) // Searching by the "name" field
        .get();

    // Check if the query returned any documents
    if (query.docs.isEmpty) {
      print("❌ No data found for: $degreeTitle in collection: $collection");
      return null; // Return null if no documents found
    } else {
      print("✅ Fetching data from collection: $collection for: $degreeTitle");
      return query.docs.first; // Return the first document if found
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
                  image: AssetImage("assets/2.jpg"), // Background image for the screen
                  fit: BoxFit.cover, // Cover the entire screen
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken), // Darken the image
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back Button & Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Padding for the container
                  width: double.infinity, // Full width
                  color: Colors.black.withOpacity(0.7), // Background color with opacity
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white), // Back button icon
                        onPressed: () => Navigator.pop(context), // Navigate back on press
                      ),
                      const SizedBox(width: 10), // Space between button and title
                      Expanded(
                        child: Text(
                          degreeTitle, // Display the degree title
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // Title style
                          textAlign: TextAlign.center, // Center align the title
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot?>(
                    future: getDegreeDetails(collection, degreeTitle), // Fetch degree details
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            "Degree details not found.", // Message if no details found
                            style: TextStyle(fontSize: 18, color: Colors.white), // Style for the message
                          ),
                        );
                      }
                      var data = snapshot.data!.data() as Map<String, dynamic>; // Extract data from snapshot
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // Padding for the details container
                          child: Container(
                            padding: const EdgeInsets.all(16), // Inner padding
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85), // Background color with opacity
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)], // Shadow effect
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                              children: [
                                const SizedBox(height: 10), // Space at the top
                                const Text("Course Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), // Section title
                                const SizedBox(height: 10), // Space below the title
                                Text(
                                  data['details'] ?? "No detailed information available.", // Display details or fallback message
                                  style: const TextStyle(fontSize: 16), // Style for the details text
                                  textAlign: TextAlign.justify, // Justify text alignment
                                ),
                                const SizedBox(height: 20), // Space at the bottom
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
