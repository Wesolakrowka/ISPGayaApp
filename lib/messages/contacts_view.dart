import 'package:flutter/material.dart'; // Importing Flutter's material design library for building UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user authentication
import 'package:firebase_messaging/firebase_messaging.dart'; // Importing Firebase Messaging for push notifications
import 'chat_screen.dart'; // Importing the ChatScreen widget for messaging functionality

// ContactsView is a StatefulWidget that displays a list of contacts and allows users to chat with them
class ContactsView extends StatefulWidget {
  const ContactsView({super.key}); // Constructor for ContactsView

  @override
  _ContactsViewState createState() => _ContactsViewState(); // Creating the state for ContactsView
}

// _ContactsViewState is the state class for ContactsView
class _ContactsViewState extends State<ContactsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for user authentication
  final TextEditingController _searchController = TextEditingController(); // Controller for the search input field
  String searchQuery = ""; // Variable to hold the current search query
  String? currentUserEmail; // Variable to store the current user's email

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    _initializeUser(); // Initializing the current user
    _setupFCM(); // Setting up Firebase Cloud Messaging
  }

  // Function to initialize the current user and retrieve their email
  void _initializeUser() {
    User? user = _auth.currentUser; // Get the currently authenticated user
    if (user != null) { // If a user is logged in
      setState(() {
        currentUserEmail = user.email; // Store the user's email
      });
    }
  }

  // Function to set up Firebase Cloud Messaging for notifications
  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance; // Instance of FirebaseMessaging

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, // Allow alert notifications
      badge: true, // Allow badge notifications
      sound: true, // Allow sound notifications
    );

    // Check if notifications are enabled
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notifications enabled"); // Log that notifications are enabled
    }

    // Get FCM token for the current user
    String? token = await messaging.getToken(); // Retrieve the FCM token
    if (token != null && currentUserEmail != null) { // If token and email are available
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Access the 'users' collection
          .doc(currentUserEmail) // Get the document for the current user
          .get();

      // If the user document exists, update it with the FCM token
      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserEmail)
            .update({'fcmToken': token}); // Update the user's FCM token
      } else {
        print("⚠️ User document does not exist: $currentUserEmail"); // Log if the user document does not exist
      }
    }

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show a snackbar with the message title when a new message is received
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📩 New message from ${message.notification?.title ?? "Unknown"}"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the current user's email is not available, show a loading indicator
    if (currentUserEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"), // Title of the app bar
        backgroundColor: const Color(0xFFFA8742), // Background color of the app bar
      ),
      body: Column(
        children: [
          // **Search Users**
          Padding(
            padding: const EdgeInsets.all(10.0), // Padding around the search field
            child: TextField(
              controller: _searchController, // Controller for the search input
              style: const TextStyle(color: Colors.black), // Text color for the input
              decoration: InputDecoration(
                labelText: "Search users...", // Label for the search input
                prefixIcon: const Icon(Icons.search, color: Colors.white), // Search icon
                filled: true, // Fill the background of the input
                fillColor: const Color(0xFFFA8742), // Background color of the input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the input
                  borderSide: BorderSide.none, // No border side
                ),
              ),
              onChanged: (value) { // Callback for when the input changes
                setState(() {
                  searchQuery = value.toLowerCase(); // Update the search query
                });
              },
            ),
          ),

          //  **Show search results if user is searching**
          if (searchQuery.isNotEmpty) // If there is a search query
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(), // Stream of user documents
                builder: (context, snapshot) {
                  if (!snapshot.hasData) { // If there is no data yet
                    return const Center(child: CircularProgressIndicator()); // Show loading indicator
                  }

                  var userDocs = snapshot.data!.docs; // Get the list of user documents

                  // Filter users based on the search query
                  var filteredUsers = userDocs.where((doc) {
                    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>; // Get user data
                    if (!userData.containsKey('email')) return false; // Ensure email exists

                    String email = userData['email'].toLowerCase(); // Get email and convert to lowercase
                    String name = userData.containsKey('name') ? userData['name'].toLowerCase() : ""; // Get name if it exists

                    // Check if email or name contains the search query
                    return email.contains(searchQuery) || name.contains(searchQuery);
                  }).toList();

                  if (filteredUsers.isEmpty) { // If no users match the search
                    return const Center(child: Text("No users found.")); // Show no users found message
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Allow the list to take only the space it needs
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
                    itemCount: filteredUsers.length, // Number of filtered users
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index]; // Get the user at the current index
                      Map<String, dynamic> userData = user.data() as Map<String, dynamic>; // Get user data

                      String userEmail = userData['email']; // Get user's email
                      String userName = userData.containsKey('name') ? userData['name'] : userEmail; // Get user's name or fallback to email

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300, // Background color for the avatar
                          child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.black)), // Display first letter of the user's name
                        ),
                        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)), // Display user's name
                        subtitle: Text(userEmail), // Display user's email
                        onTap: () { // Callback for when the list item is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen(receiverEmail: userEmail)), // Navigate to the chat screen
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

          // **User Conversations - Sorted by Latest Message**
          if (searchQuery.isEmpty) // If there is no search query
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats') // Access the 'chats' collection
                    .where('participants', arrayContains: currentUserEmail) // Filter chats that include the current user
                    .orderBy('timestamp', descending: true) // 🔥 Ensures latest messages are at the top
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) { // If there is no data yet
                    return const Center(child: CircularProgressIndicator()); // Show loading indicator
                  }

                  var chatDocs = snapshot.data!.docs; // Get the list of chat documents

                  if (chatDocs.isEmpty) { // If there are no chat documents
                    return const Center(child: Text("No conversations yet.")); // Show no conversations message
                  }

                  return ListView.builder(
                    itemCount: chatDocs.length, // Number of chat documents
                    itemBuilder: (context, index) {
                      var chat = chatDocs[index]; // Get the chat document at the current index
                      List<dynamic> participants = chat['participants']; // Get the list of participants in the chat

                      // Ensure 'otherUserEmail' is valid before calling Firestore
                      String otherUserEmail = participants.firstWhere(
                        (email) => email != currentUserEmail, // Find the email that is not the current user's
                        orElse: () => "", // Default to an empty string if not found
                      );

                      if (otherUserEmail.isEmpty) { // If no valid other user email is found
                        return const SizedBox(); // Prevents calling Firestore with an empty string
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(otherUserEmail).get(), // Get the user document for the other participant
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) { // If the user document is still loading
                            return const SizedBox(); // Prevents empty UI while loading
                          }

                          String userName = otherUserEmail; // Default to email if no user doc exists

                          if (userSnapshot.hasData && userSnapshot.data!.exists) { // If the user document exists
                            var userData = userSnapshot.data!.data() as Map<String, dynamic>; // Get user data
                            userName = userData['name'] ?? otherUserEmail; // Get user's name or fallback to email
                          } else {
                            print("⚠️ User document does not exist: $otherUserEmail"); // Debugging message
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFA8742), // Background color for the avatar
                              child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)), // Display first letter of the user's name
                            ),
                            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)), // Display user's name
                            subtitle: Text(chat['lastMessage'] ?? "No messages"), // Display the last message or a default message
                            onTap: () { // Callback for when the list item is tapped
                              FirebaseFirestore.instance.collection('chats').doc(chat.id).update({
                                'unreadMessages.$currentUserEmail': false, // Mark the chat as read
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(receiverEmail: otherUserEmail)), // Navigate to the chat screen
                              );
                            },
                          );
                        },
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
