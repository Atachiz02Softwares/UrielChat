import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';
import '../utils/strings.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(String chatId, String collection, ChatMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatRef = _firestore
        .collection(Strings.chats)
        .doc(user.uid)
        .collection(collection)
        .doc(chatId);

    await chatRef.set({
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
    });
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    final chatRef = _firestore
        .collection(Strings.chats)
        .doc(user.uid)
        .collection(Strings.userChats)
        .doc(chatId);

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

  Future<List<Map<String, String>>> getRecentChats(String userId) async {
    final querySnapshot = await _firestore
        .collection(Strings.chats)
        .doc(userId)
        .collection(Strings.userChats)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final messages = doc['messages'] as List<dynamic>? ?? [];
      final firstMessage = messages.isNotEmpty
          ? ChatMessage.fromMap(messages.first).content
          : 'No messages yet';
      return {
        'chatId': doc.id,
        'firstMessage': firstMessage,
      };
    }).toList();
  }

  // deleteChat method
  Future<void> deleteChat(String chatId) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore
        .collection(Strings.chats)
        .doc(user!.uid)
        .collection(Strings.userChats)
        .doc(chatId)
        .delete();
  }
}
