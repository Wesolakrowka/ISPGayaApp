import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 Pobieranie listy użytkowników do wyboru odbiorcy wiadomości
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 🔥 Tworzenie czatu lub aktualizacja istniejącego
  Future<void> createOrUpdateChat(String receiverEmail, String lastMessage) async {
    String currentUserEmail = _auth.currentUser!.email!;
    String chatId = getChatId(currentUserEmail, receiverEmail);

    DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);

    DocumentSnapshot chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      print("🆕 Tworzę nowy czat: $chatId");
      await chatDoc.set({
        'participants': [currentUserEmail, receiverEmail],
        'lastMessage': lastMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDoc.set({
        'lastMessage': lastMessage,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // 🔥 Wysyłanie wiadomości
  Future<void> sendMessage(String receiverEmail, String messageText) async {
    String currentUserEmail = _auth.currentUser!.email!;
    String chatId = getChatId(currentUserEmail, receiverEmail);

    DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);
    DocumentSnapshot chatSnapshot = await chatDoc.get();

    // Jeśli czat nie istnieje, utwórz go razem z participants
    if (!chatSnapshot.exists) {
      print("🆕 Tworzę nową rozmowę: $chatId");
      await chatDoc.set({
        'participants': [currentUserEmail, receiverEmail],
        'lastMessage': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDoc.set({
        'lastMessage': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 🔥 Zapisz wiadomość w Firestore
    await chatDoc.collection('messages').add({
      'senderEmail': currentUserEmail,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("✅ Wiadomość wysłana i zapisano participants w Firestore!");
  }

  // 🔥 Pobieranie wiadomości dla danego czatu
  Stream<QuerySnapshot> getMessages(String receiverEmail) {
    String currentUserEmail = _auth.currentUser!.email!;
    String chatId = getChatId(currentUserEmail, receiverEmail);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 🔥 Generowanie unikalnego ID dla czatu
  String getChatId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort();
    return emails.join("_");
  }
}
