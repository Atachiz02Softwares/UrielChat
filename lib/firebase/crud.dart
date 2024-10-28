import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../providers/chat_provider.dart';
import '../utils/strings.dart';

class CRUD {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference _storageRef = FirebaseStorage.instance.ref();

  Future<void> initializeUser(User user) async {
    final snapshot = await _firestore.collection(Strings.users).doc(user.uid).get();
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      await user.updateProfile(
        displayName: userData['name'],
        photoURL: userData['photoURL'],
      );
    } else {
      // If the user document does not exist, create it with default values
      await _firestore.collection(Strings.users).doc(user.uid).set({
        'name': user.displayName,
        'photoURL': user.photoURL,
      });
    }
  }

  Future<void> initializeChat(String userId) async {
    final doc = await _firestore.collection(Strings.chats).doc(userId).get();
    if (!doc.exists) {
      await _firestore.collection(Strings.chats).doc(userId).set({});
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

  Future<String> uploadImageToStorage(Uint8List image, String chatId) async {
    final imageRef = _storageRef.child('images/${user!.uid}/$chatId/${generateChatId()}.png');
    await imageRef.putData(image);
    return await imageRef.getDownloadURL();
  }

  Future<void> deleteImagesFromStorage(String chatId) async {
    final imagesRef = _storageRef.child('images/${user!.uid}/$chatId');

    final listResult = await imagesRef.listAll();
    await Future.wait(listResult.items.map((item) => item.delete()));
  }

  Future<String> fetchCurrentPlan(String userId) async {
    final userDoc = _firestore.collection(Strings.users).doc(userId);
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      return userData['tier'] ?? 'free';
    }
    return 'free';
  }

  Map<String, dynamic>? _cachedUserData;
  DateTime? _lastFetchTime;

  Future<void> resetSubIfExpired(DateTime now) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check if cached data is available and not outdated (older than 5 minutes)
    if (_cachedUserData == null ||
        _lastFetchTime == null ||
        now.difference(_lastFetchTime!).inMinutes > 5) {
      final userDoc = _firestore.collection(Strings.users).doc(user.uid);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) return;

      _cachedUserData = userSnapshot.data();
      _lastFetchTime = now;
    }

    final transactions = _cachedUserData?['transactions'] as List<dynamic>?;

    if (transactions == null || transactions.isEmpty) return;

    // Get the latest transaction timestamp
    final latestTransaction = transactions.last;
    final latestTimestamp =
        (latestTransaction['timestamp'] as Timestamp).toDate();

    // Check if the latest transaction is older than a month
    if (now.difference(latestTimestamp).inDays > 30) {
      await _firestore.collection(Strings.users).doc(user.uid).update({
        'tier': 'free',
        'dailyLimit': Strings.free,
      });
    }
  }
}
