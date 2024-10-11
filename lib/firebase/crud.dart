import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/strings.dart';

class CRUD {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getSystemInstructions() async {
    final doc =
        await _firestore.collection('aiConfigs').doc(Strings.instId).get();
    if (doc.exists) {
      return doc.data()?['systemInstructions'] as String?;
    }
    return null;
  }

  Future<void> initializeUser(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      await user.updateProfile(
        displayName: userData['name'],
        photoURL: userData['photoURL'],
      );
    }
  }

  Future<void> initializeChat(String userId) async {
    final doc = await _firestore.collection('chats').doc(userId).get();
    if (!doc.exists) {
      await _firestore.collection('chats').doc(userId).set({});
    }
  }

  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }
}
