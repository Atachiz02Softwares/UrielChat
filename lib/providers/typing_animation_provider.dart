import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingAnimationNotifier extends StateNotifier<Map<String, bool>> {
  TypingAnimationNotifier() : super({});

  void showAnimation(String chatId) {
    state = {...state, chatId: true};
  }

  void resetAnimation(String chatId) {
    state = {...state, chatId: false};
  }

  bool hasShownAnimation(String chatId) {
    return state[chatId] ?? false;
  }
}

final typingAnimationProvider =
    StateNotifierProvider<TypingAnimationNotifier, Map<String, bool>>(
  (ref) => TypingAnimationNotifier(),
);
