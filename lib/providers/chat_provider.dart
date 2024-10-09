import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/crud.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
  final String _chatId;

  ChatProvider(this._chatId, this._chatService) : super([]) {
    _init();
  }

  void _init() {
    _chatService.getMessages(_chatId).listen((messages) {
      state = messages;
    });
  }

  Future<void> loadChat(String userId) async {
    // TODO: Implement the logic to load chat messages for the user
  }

  Future<void> addMessage(ChatMessage message) async {
    await _chatService.saveMessage(_chatId, message);
  }

  Future<void> deleteCurrentChat() async {
    // Implement the logic to delete the current chat
  }

  Future<void> clearMessages() async {
    state = [];
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, List<ChatMessage>>(
  (ref) {
    final chatId = generateChatId();
    return ChatProvider(chatId, ChatService());
  },
);

String generateChatId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

final crudProvider = Provider<CRUD>((ref) => CRUD());
