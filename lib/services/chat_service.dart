import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(String chatId, ChatMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.set({
      'userId': user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
    });
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    final chatRef = _firestore.collection('chats').doc(chatId);
    return chatRef.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data != null && data['messages'] != null) {
        return (data['messages'] as List)
            .map((message) => ChatMessage.fromMap(message))
            .toList();
      }
      return [];
    });
  }

  Future<List<String>> getRecentChats(String userId) async {
    final querySnapshot = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }
}
