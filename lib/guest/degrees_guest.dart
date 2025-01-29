import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database access
import 'package:applicationispgaya/guest/degree_details.dart'; // Importing the DegreeDetailView for displaying degree details

// DegreesPage is a StatefulWidget that manages the state of the degrees view
class DegreesPage extends StatefulWidget {
  const DegreesPage({super.key}); // Constructor for DegreesPage

  @override
  _DegreesPageState createState() => _DegreesPageState(); // Creating the state for DegreesPage
}

// _DegreesPageState is the state class for DegreesPage
class _DegreesPageState extends State<DegreesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController; // TabController to manage tab navigation

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    _tabController = TabController(length: 3, vsync: this); // Initializing the TabController with 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose(); // Disposing of the TabController when the widget is removed from the widget tree
    super.dispose(); // Calling the superclass's dispose
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Building the main scaffold for the DegreesPage
      appBar: AppBar( // AppBar at the top of the screen
        title: const Text("Degrees"), // Title of the AppBar
        backgroundColor: const Color(0xFFFA8742), // Background color of the AppBar
        bottom: TabBar( // TabBar for switching between different degree categories
          controller: _tabController, // Controller for the TabBar
          labelColor: Colors.white, // Color of the selected tab label
          indicatorColor: Colors.white, // Color of the tab indicator
          tabs: const [ // Defining the tabs
            Tab(text: "CTeSP"), // First tab for CTeSP
            Tab(text: "Degrees"), // Second tab for Degrees
            Tab(text: "Masters"), // Third tab for Masters
          ],
        ),
      ),
      body: TabBarView( // Body of the scaffold containing the TabBarView
        controller: _tabController, // Controller for the TabBarView
        children: [ // Children of the TabBarView
          _buildDegreeList("ctesp"),  // Building the degree list for CTeSP
          _buildDegreeList("degrees"), // Building the degree list for Degrees
          _buildDegreeList("masters"), // Building the degree list for Masters
        ],
      ),
    );
  }

  //  Function to build a list of degrees for a given category
  Widget _buildDegreeList(String collectionName) {
    return Stack( // Using a Stack to overlay the background image and the content
      children: [
        // 📷 Background Image
        Positioned.fill( // Positioning the background image to fill the available space
          child: Container(
            decoration: BoxDecoration( // Decoration for the background container
              image: DecorationImage( // Image decoration for the background
                image: AssetImage("assets/2.jpg"), // Background image asset
                fit: BoxFit.cover, // Cover the entire area
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken), // Darken the image
              ),
            ),
          ),
        ),

        SafeArea( // Ensuring content is displayed within the safe area of the device
          child: StreamBuilder<QuerySnapshot>( // StreamBuilder to listen for real-time updates from Firestore
            stream: FirebaseFirestore.instance.collection(collectionName).snapshots(), // Listening to the specified collection
            builder: (context, snapshot) { // Builder function to build the UI based on the snapshot
              if (snapshot.connectionState == ConnectionState.waiting) { // Checking if the connection is still waiting
                return const Center(child: CircularProgressIndicator()); // Displaying a loading indicator
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // Checking if there is no data or if the documents are empty
                return const Center( // Displaying a message if no courses are available
                  child: Text("No courses available at the moment.", style: TextStyle(color: Colors.white)),
                );
              }

              return ListView( // Building a ListView to display the degrees
                padding: const EdgeInsets.all(16.0), // Padding for the ListView
                children: snapshot.data!.docs.map((doc) { // Mapping through the documents in the snapshot
                  var data = doc.data() as Map<String, dynamic>; // Extracting data from the document
                  String name = data['name'] ?? "Unknown"; // Getting the name of the degree or defaulting to "Unknown"
                  String description = data['description'] ?? "No description available."; // Getting the description or defaulting to a placeholder
                  return _degreeTile(context, name, description, collectionName); // Building a tile for each degree
                }).toList(), // Converting the mapped list to a List
              );
            },
          ),
        ),
      ],
    );
  }

  //  Function to create a tile for each degree in the list
  Widget _degreeTile(BuildContext context, String title, String description, String collection) {
    return Card( // Creating a Card widget for the degree tile
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for the card
      elevation: 3, // Elevation for shadow effect
      child: ListTile( // ListTile for displaying the degree information
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // Title of the degree
        subtitle: Text(description), // Description of the degree
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFA8742)), // Arrow icon indicating navigation
        onTap: () => Navigator.push( // On tap, navigate to the DegreeDetailView
          context,
          MaterialPageRoute(
            builder: (context) => DegreeDetailView(degreeTitle: title, collection: collection), // Passing the degree title and collection to the detail view
          ),
        ),
      ),
    );
  }
}
