import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../custom_widgets/custom.dart';
import '../firebase/firebase.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
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
      _appBarTitle = Strings.newChat;

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _aiResponseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = ChatMessage(
      sender: 'user',
      content: _controller.text,
      timestamp: DateTime.now(),
    );
    await ref.read(chatProvider.notifier).addMessage(message);

    setState(() {
      _isLoading = true;
    });

    final chatHistory = ref.read(chatProvider).map((message) {
      return message
          .toMap()
          .map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    final chatHistoryString = chatHistory.map((e) => e.toString()).join('\n');

    final prompt = '''
Based on the following chat history, limit responses to the topic of $_selectedTopic.
Respond with a $_selectedTone tone and focus on a $_selectedMode mode of conversation.
###Do not mention "User Defined" in your response, just ask the user to choose
what they'd like to talk about.### Chat History:\n$chatHistoryString
''';

    try {
      final response = await AI.model.generateContent([Content.text(prompt)]);
      final aiMessage = ChatMessage(
        sender: 'AI',
        content: response.text!,
        timestamp: DateTime.now(),
      );
      await ref.read(chatProvider.notifier).addMessage(aiMessage);

      _aiResponseCount++;

      if (_aiResponseCount >= 3) {
        _updateAppBarTitle(chatHistoryString);
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        sender: 'system',
        content: 'Error: $e',
        timestamp: DateTime.now(),
      );
      await ref.read(chatProvider.notifier).addMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateAppBarTitle(String chatHistory) async {
    final prompt = '''
  Based on the following chat history, generate a suitable title for the AppBar.
  Chat History:\n$chatHistory
  The title should be concise and relevant to the conversation, not more than 5 words.
  ''';

    try {
      final response = await AI.model.generateContent([Content.text(prompt)]);
      setState(() {
        _appBarTitle = response.text!;
      });
    } catch (e) {
      setState(() {
        _appBarTitle = Strings.newChat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.07;
    final List<ChatMessage> messages = ref.watch(chatProvider);

    // Convert List<ChatMessage> to List<Map<String, String>>
    final List<Map<String, String>> messageMaps = messages.map((message) {
      return message
          .toMap()
          .map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    return Scaffold(
      appBar: ChatAppBar(
        title: _appBarTitle,
        onNewChat: _newChat,
        onFilterOptions: () => _showFilterOptions(context),
        onClearChat: _deleteCurrentChat,
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

  void _deleteCurrentChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatId = generateChatId();
      await ref.read(chatProvider.notifier).clearMessages();
      await CRUD().deleteCurrentChat(ref as Ref<Object?>, chatId);
    }
  }

  void _newChat() {
    ref.read(chatProvider.notifier).clearMessages();
    setState(() {
      _appBarTitle = Strings.newChat;
      _aiResponseCount = 0;
      _selectedTopic = Strings.userDefined;
      _selectedTone = Strings.userDefined;
      _selectedMode = Strings.userDefined;
    });
  }

  Future<void> _loadChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      await ref.read(chatProvider.notifier).loadChat(user.uid);
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
}
