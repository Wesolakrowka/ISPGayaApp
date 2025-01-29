import 'package:flutter/material.dart'; // Importing Flutter material design package for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication

// ChatScreen is a StatefulWidget that represents the chat interface
class ChatScreen extends StatefulWidget {
  final String receiverEmail; // Email of the user we are chatting with
  const ChatScreen({super.key, required this.receiverEmail}); // Constructor to initialize receiverEmail

  @override
  _ChatScreenState createState() => _ChatScreenState(); // Creating the state for this widget
}

// _ChatScreenState holds the state for ChatScreen
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore for database access

  late String chatId; // Variable to hold the unique chat ID

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    // Generating a unique chat ID based on the current user's email and the receiver's email
    chatId = getChatId(_auth.currentUser!.email!, widget.receiverEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold provides a structure for the visual interface
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>( // FutureBuilder to fetch user data asynchronously
          future: _firestore.collection('users').doc(widget.receiverEmail).get(), // Fetching user document from Firestore
          builder: (context, snapshot) { // Builder function to handle the snapshot
            if (!snapshot.hasData || !snapshot.data!.exists) { // If no data or document doesn't exist
              return Text(widget.receiverEmail); // Display the receiver's email
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>; // Extracting user data
            return Text(userData['name'] ?? widget.receiverEmail); // Display the user's name or email if name is not available
          },
        ),
        backgroundColor: const Color(0xFFFA8742), // Setting the background color of the AppBar
      ),
      body: Column( // Column to arrange the chat messages and input field vertically
        children: [
          // Section for displaying the list of messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>( // StreamBuilder to listen for real-time updates to the messages
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false) // Ordering messages by timestamp
                  .snapshots(), // Listening for snapshots of the messages
              builder: (context, snapshot) { // Builder function to handle the snapshot
                if (snapshot.connectionState == ConnectionState.waiting) { // If waiting for data
                  return const Center(child: CircularProgressIndicator()); // Show loading indicator
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // If no data or no messages
                  return const Center(child: Text("No messages yet.")); // Display a message indicating no messages
                }

                var messages = snapshot.data!.docs; // Extracting the list of messages

                return ListView.builder( // Building a list view to display messages
                  itemCount: messages.length, // Number of messages to display
                  itemBuilder: (context, index) { // Function to build each message item
                    var message = messages[index]; // Getting the message at the current index
                    bool isMe = message['senderEmail'] == _auth.currentUser!.email!; // Checking if the message is sent by the current user

                    return Align( // Aligning the message based on sender
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Align right for sent messages, left for received
                      child: Container( // Container for styling the message bubble
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Margin around the message bubble
                        padding: const EdgeInsets.all(10), // Padding inside the message bubble
                        decoration: BoxDecoration( // Decoration for the message bubble
                          color: isMe ? Color(0xFFFA8742) : Colors.grey.shade300, // Color based on sender
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        child: Column( // Column to arrange sender info and message text
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligning children to the start
                          children: [
                            // Displaying sender's name only for received messages
                            if (!isMe) // If the message is not sent by the current user
                              FutureBuilder<DocumentSnapshot>( // FutureBuilder to fetch sender's data
                                future: _firestore.collection('users').doc(message['senderEmail']).get(), // Fetching sender's user document
                                builder: (context, snapshot) { // Builder function to handle the snapshot
                                  if (!snapshot.hasData || !snapshot.data!.exists) { // If no data or document doesn't exist
                                    return Text(message['senderEmail'], // Display sender's email
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)); // Styling for the text
                                  }
                                  var userData = snapshot.data!.data() as Map<String, dynamic>; // Extracting sender's user data
                                  return Text(userData['name'] ?? message['senderEmail'], // Display sender's name or email
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)); // Styling for the text
                                },
                              ),
                            const SizedBox(height: 5), // Space between sender info and message text
                            Text( // Displaying the message text
                              message['text'], // The actual message content
                              style: const TextStyle(fontSize: 16), // Styling for the message text
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

          // Section for the text input field to send messages
          Padding(
            padding: const EdgeInsets.all(10.0), // Padding around the input field
            child: Row( // Row to arrange the input field and send button horizontally
              children: [
                Expanded( // Expanding the text field to take available space
                  child: TextField( // TextField for user input
                    controller: _messageController, // Controller to manage the input
                    decoration: const InputDecoration( // Decoration for the text field
                      hintText: "Type a message...", // Placeholder text
                      border: OutlineInputBorder(), // Border style
                    ),
                  ),
                ),
                IconButton( // Button to send the message
                  icon: Icon(Icons.send, color: Color(0xFFFA8742)), // Send icon
                  onPressed: () { // Action when the button is pressed
                    if (_messageController.text.trim().isNotEmpty) { // Check if the input is not empty
                      sendMessage(_messageController.text.trim()); // Send the message
                      _messageController.clear(); // Clear the input field
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

  // Function to send a message to Firestore
  void sendMessage(String messageText) async {
    try {
      print("Wysyłanie wiadomości: $messageText do: ${widget.receiverEmail}"); // Logging the message sending

      DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId); // Reference to the chat document

      // Setting the chat document with participants and last message
      await chatDocRef.set({
        'participants': [_auth.currentUser!.email!, widget.receiverEmail], // List of participants in the chat
        'lastMessage': messageText, // The last message sent
        'timestamp': FieldValue.serverTimestamp(), // Timestamp for the last message
      }, SetOptions(merge: true)); // Merging with existing data

      // Adding the new message to the messages collection
      await chatDocRef.collection('messages').add({
        'senderEmail': _auth.currentUser!.email!, // Email of the sender
        'text': messageText, // The message text
        'timestamp': FieldValue.serverTimestamp(), // Timestamp for the message
      });

      print("✅ Wiadomość zapisana w Firestore!"); // Logging successful message saving

    } catch (e) {
      print("❌ Błąd podczas zapisu wiadomości: $e"); // Logging any errors that occur
    }
  }

  // Function to generate a unique chat ID based on two email addresses
  String getChatId(String email1, String email2) {
    List<String> emails = [email1, email2]; // Creating a list of emails
    emails.sort(); // Sorting the emails to ensure consistent order
    return emails.join("_"); // Joining the sorted emails to create a unique chat ID
  }
}
