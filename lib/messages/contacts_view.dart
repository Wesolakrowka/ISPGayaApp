import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'chat_screen.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _setupFCM();
  }

  void _initializeUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email;
      });
    }
  }

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notifications enabled");
    }

    // Get FCM token
    String? token = await messaging.getToken();
    if (token != null && currentUserEmail != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserEmail)
          .get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserEmail)
            .update({'fcmToken': token});
      } else {
        print("⚠️ User document does not exist: $currentUserEmail");
      }
    }

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📩 New message from ${message.notification?.title ?? "Unknown"}"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFFFA8742),
      ),
      body: Column(
        children: [
          // 🔍 **Search Users**
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Search users...",
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFFFA8742),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🔍 **Show search results if user is searching**
          if (searchQuery.isNotEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var userDocs = snapshot.data!.docs;

                  var filteredUsers = userDocs.where((doc) {
                    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
                    if (!userData.containsKey('email')) return false;

                    String email = userData['email'].toLowerCase();
                    String name = userData.containsKey('name') ? userData['name'].toLowerCase() : "";

                    return email.contains(searchQuery) || name.contains(searchQuery);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text("No users found."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      Map<String, dynamic> userData = user.data() as Map<String, dynamic>;

                      String userEmail = userData['email'];
                      String userName = userData.containsKey('name') ? userData['name'] : userEmail;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.black)),
                        ),
                        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(userEmail),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen(receiverEmail: userEmail)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

          // 🔥 **User Conversations - Sorted by Latest Message**
          if (searchQuery.isEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: currentUserEmail)
                    .orderBy('timestamp', descending: true) // 🔥 Ensures latest messages are at the top
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var chatDocs = snapshot.data!.docs;

                  if (chatDocs.isEmpty) {
                    return const Center(child: Text("No conversations yet."));
                  }

                  return ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      var chat = chatDocs[index];
                      List<dynamic> participants = chat['participants'];

                      // Ensure 'otherUserEmail' is valid before calling Firestore
                      String otherUserEmail = participants.firstWhere(
                        (email) => email != currentUserEmail,
                        orElse: () => "",
                      );

                      if (otherUserEmail.isEmpty) {
                        return const SizedBox(); // Prevents calling Firestore with an empty string
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(otherUserEmail).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(); // Prevents empty UI while loading
                          }

                          String userName = otherUserEmail; // Default to email if no user doc exists

                          if (userSnapshot.hasData && userSnapshot.data!.exists) {
                            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                            userName = userData['name'] ?? otherUserEmail;
                          } else {
                            print("⚠️ User document does not exist: $otherUserEmail"); // Debugging message
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFA8742),
                              child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(chat['lastMessage'] ?? "No messages"),
                            onTap: () {
                              FirebaseFirestore.instance.collection('chats').doc(chat.id).update({
                                'unreadMessages.$currentUserEmail': false,
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(receiverEmail: otherUserEmail)),
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
