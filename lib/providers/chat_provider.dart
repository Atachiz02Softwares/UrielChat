import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'typing_animation_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatProvider = StateNotifierProvider<ChatProvider, List<ChatMessage>>(
  (ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatId = generateChatId();
    return ChatProvider(chatId, ref.read(chatServiceProvider), ref);
  },
);

class ChatProvider extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
  final String _chatId;
  final StateNotifierProviderRef<ChatProvider, List<ChatMessage>> _ref;

  ChatProvider(this._chatId, this._chatService, this._ref) : super([]) {
    _init();
  }

  void _init() {
    _chatService.getMessages(_chatId).listen((messages) {
      state = messages;
    });
  }

  Future<void> addMessage(ChatMessage message) async {
    await _chatService.saveMessage(_chatId, message);
    if (message.sender == 'AI') {
      _ref.read(typingAnimationProvider.notifier).resetAnimation();
    }
  }

  Future<void> clearMessages() async {
    state = [];
  }

  Future<void> loadChat(String userId) async {
    final messages = await _chatService.getMessages(_chatId).first;
    state = messages;
  }
}

String generateChatId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}
