import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;
  const ChatScreen({super.key, required this.receiverEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = getChatId(_auth.currentUser!.email!, widget.receiverEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(widget.receiverEmail).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(widget.receiverEmail);
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Text(userData['name'] ?? widget.receiverEmail);
          },
        ),
        backgroundColor: const Color(0xFFFA8742
), // 🔥 Pomarańczowy header
      ),
      body: Column(
        children: [
          // 🔥 LISTA WIADOMOŚCI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderEmail'] == _auth.currentUser!.email!;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFFFA8742) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔥 WYŚWIETLANIE NADAWCY TYLKO DLA OTRZYMANYCH WIADOMOŚCI
                            if (!isMe)
                              FutureBuilder<DocumentSnapshot>(
                                future: _firestore.collection('users').doc(message['senderEmail']).get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    return Text(message['senderEmail'],
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54));
                                  }
                                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                                  return Text(userData['name'] ?? message['senderEmail'],
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54));
                                },
                              ),
                            const SizedBox(height: 5),
                            Text(
                              message['text'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔥 POLE TEKSTOWE DO WYSYŁANIA WIADOMOŚCI
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFFA8742)),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      sendMessage(_messageController.text.trim());
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String messageText) async {
    try {
      print("📩 Wysyłanie wiadomości: $messageText do: ${widget.receiverEmail}");

      DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId);

      await chatDocRef.set({
        'participants': [_auth.currentUser!.email!, widget.receiverEmail],
        'lastMessage': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await chatDocRef.collection('messages').add({
        'senderEmail': _auth.currentUser!.email!,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Wiadomość zapisana w Firestore!");

    } catch (e) {
      print("❌ Błąd podczas zapisu wiadomości: $e");
    }
  }

  String getChatId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort();
    return emails.join("_");
  }
}
