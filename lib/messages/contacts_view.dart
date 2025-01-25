import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFFFA8742),
      ),
      body: Column(
        children: [
          // 🔍 WYSZUKIWANIE UŻYTKOWNIKÓW (Teraz wyniki pojawiają się natychmiast)
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

          // 🔍 **Natychmiastowe wyniki wyszukiwania pod polem wyszukiwania**
          if (searchQuery.isNotEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

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
                    shrinkWrap: true, // 🔥 Pozwala na wyświetlanie wyników bez błędów
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
                          child: Text(userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.black)),
                        ),
                        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(userEmail),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(receiverEmail: userEmail),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

          // 🔥 **Lista konwersacji**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var currentUserEmail = _auth.currentUser!.email!;
                var chatDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>?;
                  return data?['participants']?.contains(currentUserEmail) ?? false;
                }).toList();

                if (chatDocs.isEmpty) return const Center(child: Text("No conversations yet."));

                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    var chat = chatDocs[index];
                    List<dynamic> participants = chat['participants'];

                    if (participants.length < 2) return const SizedBox();

                    String otherUserEmail = participants.firstWhere(
                      (email) => email != currentUserEmail,
                      orElse: () => "",
                    );

                    if (otherUserEmail.isEmpty) return const SizedBox();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherUserEmail).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        String userName = userData['name'] ?? otherUserEmail;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFA8742
),
                            child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(chat['lastMessage'] ?? "No messages"),
                          onTap: () {
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
