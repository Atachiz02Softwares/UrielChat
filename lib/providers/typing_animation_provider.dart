import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingAnimationNotifier extends StateNotifier<bool> {
  TypingAnimationNotifier() : super(false);

  void showAnimation() {
    state = true;
  }

  void resetAnimation() {
    state = false;
  }
}

final typingAnimationProvider = StateNotifierProvider<TypingAnimationNotifier, bool>(
      (ref) => TypingAnimationNotifier(),
);