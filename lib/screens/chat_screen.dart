import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom.dart';
import '../firebase/firebase.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';
import '../utils/utilities.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? searchQuery;

  const ChatScreen({super.key, required this.chatId, this.searchQuery});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _appBarTitle = Strings.newChat, _chatId = generateChatId();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _chatId = widget.chatId;
    Future.delayed(Duration.zero, () {
      ref.read(currentChatIdProvider.notifier).state = _chatId;
    });
    await _loadChat();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _controller.text = widget.searchQuery!;
      await _sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.07;
    final List<ChatMessage> messages = ref.watch(chatProvider(_chatId));

    final List<Map<String, String>> messageMaps = messages.map((message) {
      return message
          .toMap()
          .map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    return Scaffold(
      appBar: ChatAppBar(
        title: _appBarTitle,
        onNewChat: newChat,
        onDeleteChat: deleteChat,
        iconSize: iconSize,
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const ChatHeader()
                      : ChatBody(messages: messageMaps),
                ),
                InputBar(
                  controller: _controller,
                  isLoading: _isLoading,
                  onSendMessage: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      await ref.read(chatProvider(_chatId).notifier).loadChat(user.uid);
    }
  }

  Future<void> deleteChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatId = ref.read(chatProvider(_chatId).notifier).chatId;
      await CRUD().deleteChat(chatId);
      await newChat();
    }
  }

  Future<void> newChat() async {
    setState(() {
      _controller.clear();
      _isLoading = false;
      _appBarTitle = Strings.newChat;
      _chatId = generateChatId();
    });

    ref.read(currentChatIdProvider.notifier).state = _chatId;

    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(chatProvider(_chatId).notifier).clearMessages();
      ref.read(chatProvider(_chatId).notifier).chatId = _chatId;
      await ref.read(chatProvider(_chatId).notifier).loadChat(user.uid);
    }
  }

  Future<void> _sendMessage() async {
    await Utilities.sendMessage(
      chatId: _chatId,
      controller: _controller,
      ref: ref,
      setLoading: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
    );
  }
}
