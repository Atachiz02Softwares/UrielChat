import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom.dart';
import '../models/chat_message.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';
import '../utils/utilities.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? searchQuery;
  final bool fromRecent;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.searchQuery,
    required this.fromRecent,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _chatId = generateChatId();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    ref.read(planProvider.notifier).fetchCurrentPlan(ref);
  }

  Future<void> _initialize() async {
    _chatId = widget.chatId;
    Future.delayed(Duration.zero, () {
      ref.read(currentChatIdProvider.notifier).state = _chatId;
    });
    await _loadChat();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await _sendMessage(widget.searchQuery!);
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
        leading: widget.fromRecent
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 30),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Strings.newChat,
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
                      : ChatBody(messages: messageMaps, chatId: _chatId),
                ),
                InputBar(
                  controller: _controller,
                  waiting: _isLoading,
                  onSendMessage: () {
                    final prompt = _controller.text;
                    _controller.clear();
                    _sendMessage(prompt);
                  },
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
      await ref.read(chatProvider(_chatId).notifier).loadChat(
            user.uid,
            Strings.userChats,
          );
    }
  }

  Future<void> deleteChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatId = ref.read(chatProvider(_chatId).notifier).chatId;
      await ref
          .read(chatProvider(chatId).notifier)
          .deleteChat(Strings.userChats);
      await newChat();
    }
  }

  Future<void> newChat() async {
    setState(() {
      _controller.clear();
      _isLoading = false;
      _chatId = generateChatId();
    });

    ref.read(currentChatIdProvider.notifier).state = _chatId;

    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(chatProvider(_chatId).notifier).clearMessages();
      ref.read(chatProvider(_chatId).notifier).chatId = _chatId;
      await ref.read(chatProvider(_chatId).notifier).loadChat(
            user.uid,
            Strings.userChats,
          );
    }
  }

  Future<void> _sendMessage(String prompt) async {
    await Utilities.sendChatMessage(
      chatId: _chatId,
      prompt: prompt,
      ref: ref,
      setLoading: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
          _controller.clear();
        });
      },
    );
  }
}
