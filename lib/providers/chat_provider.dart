import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'typing_animation_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatProvider =
    StateNotifierProvider.family<ChatProvider, List<ChatMessage>, String>(
        (ref, chatId) {
  final chatService = ref.read(chatServiceProvider);
  return ChatProvider(chatId, chatService, ref);
});

final currentChatIdProvider = StateProvider<String?>((ref) => null);

final aiResponseCountProvider =
    StateProvider<int>((ref) => 0); // Added provider

class ChatProvider extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
  String _chatId;
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

  String get chatId => _chatId;

  set chatId(String id) {
    _chatId = id;
  }
}

String generateChatId() => DateTime.now().millisecondsSinceEpoch.toString();
