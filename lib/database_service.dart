import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore for database operations
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance of Firestore to interact with the database
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth to manage user authentication

  // Function to retrieve a list of users for selecting a message recipient
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) { // Listening to the 'users' collection for real-time updates
      return snapshot.docs.map((doc) => doc.data()).toList(); // Mapping each document to its data and returning as a list
    });
  }

  //  Function to create a new chat or update an existing one
  Future<void> createOrUpdateChat(String receiverEmail, String lastMessage) async {
    String currentUserEmail = _auth.currentUser!.email!; // Getting the current user's email
    String chatId = getChatId(currentUserEmail, receiverEmail); // Generating a unique chat ID based on user emails

    DocumentReference chatDoc = _firestore.collection('chats').doc(chatId); // Reference to the chat document in Firestore

    DocumentSnapshot chatSnapshot = await chatDoc.get(); // Fetching the chat document snapshot

    if (!chatSnapshot.exists) { // Checking if the chat document does not exist
      print("🆕 Tworzę nowy czat: $chatId"); // Logging the creation of a new chat
      await chatDoc.set({ // Creating a new chat document with participants and last message
        'participants': [currentUserEmail, receiverEmail], // List of participants in the chat
        'lastMessage': lastMessage, // Storing the last message sent
        'timestamp': FieldValue.serverTimestamp(), // Storing the current server timestamp
      });
    } else {
      await chatDoc.set({ // Updating the existing chat document with the last message and timestamp
        'lastMessage': lastMessage, // Updating the last message
        'timestamp': FieldValue.serverTimestamp(), // Updating the timestamp
      }, SetOptions(merge: true)); // Merging the new data with existing data
    }
  }

  // Function to send a message
  Future<void> sendMessage(String receiverEmail, String messageText) async {
    String currentUserEmail = _auth.currentUser!.email!; // Getting the current user's email
    String chatId = getChatId(currentUserEmail, receiverEmail); // Generating a unique chat ID

    DocumentReference chatDoc = _firestore.collection('chats').doc(chatId); // Reference to the chat document
    DocumentSnapshot chatSnapshot = await chatDoc.get(); // Fetching the chat document snapshot

    // If the chat does not exist, create it along with participants
    if (!chatSnapshot.exists) {
      print("🆕 Tworzę nową rozmowę: $chatId"); // Logging the creation of a new conversation
      await chatDoc.set({ // Creating a new chat document with participants and last message
        'participants': [currentUserEmail, receiverEmail], // List of participants in the chat
        'lastMessage': messageText, // Storing the last message sent
        'timestamp': FieldValue.serverTimestamp(), // Storing the current server timestamp
      });
    } else {
      await chatDoc.set({ // Updating the existing chat document with the last message and timestamp
        'lastMessage': messageText, // Updating the last message
        'timestamp': FieldValue.serverTimestamp(), // Updating the timestamp
      }, SetOptions(merge: true)); // Merging the new data with existing data
    }

    // Saving the message in Firestore
    await chatDoc.collection('messages').add({ // Adding a new message document to the 'messages' subcollection
      'senderEmail': currentUserEmail, // Storing the sender's email
      'text': messageText, // Storing the message text
      'timestamp': FieldValue.serverTimestamp(), // Storing the current server timestamp
    });

    print("✅ Wiadomość wysłana i zapisano participants w Firestore!"); // Logging successful message sending
  }

  // Function to retrieve messages for a given chat
  Stream<QuerySnapshot> getMessages(String receiverEmail) {
    String currentUserEmail = _auth.currentUser!.email!; // Getting the current user's email
    String chatId = getChatId(currentUserEmail, receiverEmail); // Generating a unique chat ID
    return _firestore // Returning a stream of message snapshots for the chat
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Ordering messages by timestamp in descending order
        .snapshots(); // Listening for real-time updates
  }

  // Function to generate a unique ID for a chat
  String getChatId(String email1, String email2) {
    List<String> emails = [email1, email2]; // Creating a list of emails
    emails.sort(); // Sorting the emails to ensure consistent chat ID generation
    return emails.join("_"); // Joining the sorted emails with an underscore to form the chat ID
  }
}
