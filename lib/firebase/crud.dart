import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
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

  Future<void> deleteCurrentChat(Ref ref, String chatId) async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatRef =
          _firestore.collection('chats').doc(user.uid).collection(chatId);
      final messages = await chatRef.get();
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await chatRef.doc().delete();
    }
  }

  Future<void> updateSubject(
      Ref ref, String? oldSubject, String newSubject) async {
    final user = ref.read(userProvider);
    if (user != null && oldSubject != null) {
      final messages = await _firestore
          .collection('chats')
          .doc(user.uid)
          .collection(oldSubject)
          .get();
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'subject': newSubject});
      }
      await batch.commit();
    }
  }
}
