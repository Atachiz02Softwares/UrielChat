import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(
    String chatId,
    ChatMessage message,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final chatRef = _firestore.collection('chats').doc(user?.uid);
    await chatRef.collection(chatId).add(message.toMap());
  }

  Stream<List<ChatMessage>> getMessages(String userId, String chatId) {
    final chatRef =
        _firestore.collection('chats').doc(userId).collection(chatId);
    return chatRef.orderBy('timestamp', descending: false).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }
}
