import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../custom_widgets/custom.dart';
import '../models/chat_message.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';
import '../utils/utilities.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? searchQuery;
  final bool isImageGenerator;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.searchQuery,
    required this.isImageGenerator,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String _chatId = generateChatId();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool isGenerating = false;
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
        title: widget.isImageGenerator ? 'Image Generation' : Strings.newChat,
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
                      : ChatBody(
                          messages: messageMaps,
                          chatId: _chatId,
                          isImageGenerator: widget.isImageGenerator,
                        ),
                ),
                InputBar(
                  controller: _controller,
                  waiting: widget.isImageGenerator ? isGenerating : _isLoading,
                  onSendMessage: widget.isImageGenerator ? _generateImage : _sendMessage,
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
            widget.isImageGenerator
                ? Strings.userImageChats
                : Strings.userChats,
          );
    }
  }

  Future<void> deleteChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatId = ref.read(chatProvider(_chatId).notifier).chatId;
      await ref.read(chatProvider(chatId).notifier).deleteChat(
            widget.isImageGenerator
                ? Strings.userImageChats
                : Strings.userChats,
          );
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
            widget.isImageGenerator
                ? Strings.userImageChats
                : Strings.userChats,
          );
    }
  }

  Future<void> _sendMessage() async {
    await Utilities.sendChatMessage(
      chatId: _chatId,
      controller: _controller,
      ref: ref,
      setLoading: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
          _controller.clear();
        });
      },
    );
  }

  Future<void> _generateImage() async {
    setState(() {
      isGenerating = true;
      messages.add({
        "sender": Strings.user,
        "content": _controller.text,
        "timestamp": DateTime.now().toIso8601String(),
      });
    });

    try {
      img.Image baseImage = img.Image(width: 2, height: 2);
      baseImage.setPixel(0, 0, img.ColorInt32.rgba(255, 0, 0, 255));
      baseImage.setPixel(1, 0, img.ColorInt32.rgba(0, 255, 0, 255));
      baseImage.setPixel(0, 1, img.ColorInt32.rgba(0, 0, 255, 255));
      baseImage.setPixel(1, 1, img.ColorInt32.rgba(255, 255, 0, 255));
      Uint8List image = Uint8List.fromList(img.encodePng(baseImage));

      String imageUrl = await _uploadImageToStorage(image);
      await _sendMessageWithImage(imageUrl);
    } catch (error) {
      setState(() {
        isGenerating = false;
      });
      if (mounted) {
        CustomSnackBar.showSnackBar(context, 'Error generating image: $error');
      }
      debugPrint('Error generating image: $error');
    }
  }

  Future<void> _sendMessageWithImage(String imageUrl) async {
    final message = {
      "sender": "AI",
      "content": imageUrl,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(message);
    });

    await Utilities.sendChatMessage(
      chatId: widget.chatId,
      controller: _controller,
      ref: ref,
      setLoading: (bool isGenerating) {
        setState(() {
          this.isGenerating = isGenerating;
        });
      },
      imageUrl: imageUrl,
    );
  }

  Future<String> _uploadImageToStorage(Uint8List image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef
        .child('images/$userId/${widget.chatId}/${generateChatId()}.png');
    await imageRef.putData(image);
    return await imageRef.getDownloadURL();
  }
}
