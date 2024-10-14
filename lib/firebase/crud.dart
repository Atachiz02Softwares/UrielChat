import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUD {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> sendFeedback({
    required String userId,
    required String topic,
    required String feedback,
  }) async {
    final feedbackData = {
      'userId': userId,
      'topic': topic,
      'feedback': feedback,
      'timestamp': Timestamp.now(),
    };

    await _firestore.collection('feedback').doc(userId).set({
      'feedbacks': FieldValue.arrayUnion([feedbackData]),
    }, SetOptions(merge: true));
  }
}
