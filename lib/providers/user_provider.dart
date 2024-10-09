import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/crud.dart';
import '../utils/strings.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;

  UserNotifier(this.ref) : super(null) {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await CRUD().initializeUser(user);
        await CRUD().initializeChat(user.uid);
      }
      state = user;
    });
  }

  void setUser(User? user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  User? get currentUser => state;

  String get userName => state?.displayName ?? 'User';

  String get userEmail => state?.email ?? 'user@email.com';

  String get userPhotoUrl {
    return state?.photoURL ?? Strings.avatar;
  }
}
