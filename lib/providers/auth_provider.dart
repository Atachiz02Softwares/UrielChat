import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final StreamSubscription<User?> _authStateSubscription;
  final Ref ref;

  AuthNotifier(this.ref) : super(null) {
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      state = user;
      ref.read(userProvider.notifier).setUser(user);
    });
  }

  void setUser(User? user) {
    state = user;
    ref.read(userProvider.notifier).setUser(user);
  }

  Future<void> signOut() async {
    if (_auth.currentUser != null) {
      await _auth.signOut();
    } else if (_googleSignIn.currentUser != null) {
      await _googleSignIn.signOut();
    }
    state = null;
    ref.read(userProvider.notifier).clearUser();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
