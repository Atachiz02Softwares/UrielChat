import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential authResult =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'photoURL': user.photoURL,
          'tier': 'free',
          'dailyCount': 0,
          'dailyLimit': 100,
          'lastChatTime': Timestamp.now(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message.toString());
    }
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return authResult.user;
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final DocumentReference userRef =
            _firestore.collection('users').doc(user.uid);
        final DocumentSnapshot snapshot = await userRef.get();

        if (!snapshot.exists) {
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'tier': 'free',
            'dailyCount': 0,
            'dailyLimit': 100,
            'lastChatTime': Timestamp.now(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message.toString());
    }
  }
}
