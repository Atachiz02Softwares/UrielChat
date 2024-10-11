import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uriel_chat/utils/utilities.dart';

import '../custom_widgets/custom.dart';
import '../firebase/firebase.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _selectedTopic = Strings.userDefined,
      _selectedTone = Strings.userDefined,
      _selectedMode = Strings.userDefined,
      _appBarTitle = Strings.newChat,
      _chatId = generateChatId();

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final existingChatId = ref.read(currentChatIdProvider);
    if (existingChatId != null) {
      _chatId = existingChatId;
    } else {
      _chatId = generateChatId();
      ref.read(currentChatIdProvider.notifier).state =
          _chatId; // Persist chatId
    }
    await _loadChat();

    final systemInstructions = await CRUD().getSystemInstructions();
    if (systemInstructions != null) {
      Strings.systemInstructions = systemInstructions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.07;
    final List<ChatMessage> messages = ref.watch(chatProvider(_chatId));

    // Convert List<ChatMessage> to List<Map<String, String>>
    final List<Map<String, String>> messageMaps = messages.map((message) {
      return message
          .toMap()
          .map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    return Scaffold(
      appBar: ChatAppBar(
        title: _appBarTitle,
        onNewChat: newChat,
        onFilterOptions: () => _showFilterOptions(context),
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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        final filterOptions = ref.watch(filterOptionsProvider);
        return FilterOptions(
          selectedTopic: filterOptions['topic']!,
          selectedTone: filterOptions['tone']!,
          selectedMode: filterOptions['mode']!,
          onTopicChanged: (String? newValue) {
            setState(() {
              _selectedTopic = newValue!;
            });
          },
          onToneChanged: (String? newValue) {
            setState(() {
              _selectedTone = newValue!;
            });
          },
          onModeChanged: (String? newValue) {
            setState(() {
              _selectedMode = newValue!;
            });
          },
        );
      },
    );
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
      _selectedTopic = Strings.userDefined;
      _selectedTone = Strings.userDefined;
      _selectedMode = Strings.userDefined;
      _chatId = generateChatId();
    });

    ref.read(currentChatIdProvider.notifier).state =
        _chatId; // Store new chatId

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
      incrementResponseCount: (int count) {
        setState(() {
        });
      },
      updateAppBarTitle: (String chatHistory) {
        Utilities.updateAppBarTitle(
          chatHistory: chatHistory,
          setAppBarTitle: (String title) {
            setState(() {
              _appBarTitle = title;
            });
          },
        );
      },
      selectedTopic: _selectedTopic,
      selectedTone: _selectedTone,
      selectedMode: _selectedMode,
    );
  }
}
