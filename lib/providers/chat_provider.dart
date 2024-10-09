import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
  final String _userId;
  final String _chatId;

  ChatProvider(this._userId, this._chatId, this._chatService) : super([]) {
    _init();
  }

  void _init() {
    _chatService.getMessages(_userId, _chatId).listen((messages) {
      state = messages;
    });
  }

  Future<void> addMessage(ChatMessage message) async {
    await _chatService.saveMessage(_chatId, message);
  }

  Future<void> clearMessages() async {
    state = [];
  }

  Future<void> loadChat(String userId) async {
    final messages = await _chatService.getMessages(userId, _chatId).first;
    state = messages;
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, List<ChatMessage>>(
  (ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatId = generateChatId();
    return ChatProvider(userId, chatId, ChatService());
  },
);

String generateChatId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}
