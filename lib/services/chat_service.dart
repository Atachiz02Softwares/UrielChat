import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/crud.dart';
import '../models/chat_message.dart';
import '../utils/strings.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(
    String chatId,
    String collection,
    ChatMessage message,
  ) async {
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

  Stream<List<ChatMessage>> getMessages(String chatId, String collection) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    final chatRef = _firestore
        .collection(Strings.chats)
        .doc(user.uid)
        .collection(collection)
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

  Future<List<Map<String, String>>> getRecentChats(
    String userId,
    String collection,
  ) async {
    final querySnapshot = await _getRecentChatsQuery(userId, collection).get();

    return querySnapshot.docs.map((doc) {
      final messages = doc['messages'] as List<dynamic>? ?? [];
      final firstMessage = messages.isNotEmpty
          ? ChatMessage.fromMap(messages.first).content
          : 'No messages yet';
      return {
        'chatId': doc.id,
        'firstMessage': firstMessage,
        'isImageChat': collection == Strings.userImageChats ? 'true' : 'false',
      };
    }).toList();
  }

  Stream<List<Map<String, String>>> getRecentChatsStream(
    String userId,
    String collection,
  ) {
    return _getRecentChatsQuery(userId, collection)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final messages = doc['messages'] as List<dynamic>? ?? [];
        final firstMessage = messages.isNotEmpty
            ? ChatMessage.fromMap(messages.first).content
            : 'No messages yet';
        return {
          'chatId': doc.id,
          'firstMessage': firstMessage,
          'isImageChat':
              collection == Strings.userImageChats ? 'true' : 'false',
        };
      }).toList();
    });
  }

  Future<void> deleteChat(String chatId, String collection) async {
    final user = FirebaseAuth.instance.currentUser;
    await CRUD().deleteImagesFromStorage(chatId);
    await _firestore
        .collection(Strings.chats)
        .doc(user!.uid)
        .collection(collection)
        .doc(chatId)
        .delete();
  }

  Query _getRecentChatsQuery(String userId, String collection) {
    return _firestore
        .collection(Strings.chats)
        .doc(userId)
        .collection(collection)
        .orderBy('timestamp', descending: true);
  }
}
