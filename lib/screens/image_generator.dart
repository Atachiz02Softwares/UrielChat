import 'dart:io' show Platform, File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../custom_widgets/custom.dart';
import '../firebase/crud.dart';
import '../models/chat_message.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';
import '../utils/utilities.dart';

class ImageGenerator extends ConsumerStatefulWidget {
  final String chatId;

  const ImageGenerator({super.key, required this.chatId});

  @override
  ConsumerState<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends ConsumerState<ImageGenerator> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _newChatId = generateChatId();
  bool isGenerating = false;

  // final StabilityAI _ai = StabilityAI();
  // final String apiKey = Strings.stabilityAPIKey;
  // final ImageAIStyle imageAIStyle = ImageAIStyle.render3D;

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(ImageGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = Platform.isAndroid || Platform.isIOS
            ? MediaQuery.of(context).size.width / 1.5
            : MediaQuery.of(context).size.height / 2,
        iconSize = MediaQuery.of(context).size.width * 0.07;

    return Scaffold(
      appBar: ChatAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 30),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: 'Image Generator',
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
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            if (message.sender == Strings.user) {
                              // Display user message bubble
                              return Align(
                                alignment: Alignment.centerRight,
                                child: GlassContainer(
                                  borderRadius: 30,
                                  borderType: BorderType.user,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          text: message.content,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                          align: TextAlign.right,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomText(
                                              text: Strings.formatDateTime(
                                                  message.timestamp
                                                      .toIso8601String()),
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            IconButton(
                                              tooltip: 'Copy Text',
                                              icon: SvgPicture.asset(
                                                Strings.copy,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.srcIn,
                                                ),
                                                width: 16,
                                                height: 16,
                                              ),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: message.content));
                                                CustomSnackBar.showSnackBar(
                                                    context,
                                                    'Copied to clipboard');
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: GlassContainer(
                                  borderRadius: 30,
                                  borderType: BorderType.ai,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            message.content,
                                            width: imageSize,
                                            height: imageSize,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomText(
                                              text: Strings.formatDateTime(
                                                  message.timestamp
                                                      .toIso8601String()),
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            IconButton(
                                              tooltip: 'Save Image',
                                              icon: SvgPicture.asset(
                                                Strings.download,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.srcIn,
                                                ),
                                                width: 16,
                                                height: 16,
                                              ),
                                              onPressed: () {
                                                _saveImage(message.content);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
                InputBar(
                  controller: _messageController,
                  waiting: isGenerating,
                  onSendMessage: () {
                    final prompt = _messageController.text;
                    _messageController.clear();
                    if (prompt.isNotEmpty && !isGenerating) {
                      _generateImage(prompt);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateImage(String prompt) async {
    setState(() {
      isGenerating = true;
      messages.add(ChatMessage(
        sender: Strings.user,
        content: prompt,
        timestamp: DateTime.now(),
      ));
      _scrollToBottom(); // Scroll to bottom after adding a new message
    });

    try {
      img.Image baseImage = img.Image(width: 2, height: 2);
      baseImage.setPixel(0, 0, img.ColorInt32.rgba(255, 0, 0, 255));
      baseImage.setPixel(1, 0, img.ColorInt32.rgba(0, 255, 0, 255));
      baseImage.setPixel(0, 1, img.ColorInt32.rgba(0, 0, 255, 255));
      baseImage.setPixel(1, 1, img.ColorInt32.rgba(255, 255, 0, 255));
      Uint8List image = Uint8List.fromList(img.encodePng(baseImage));

      String imageUrl = await CRUD().uploadImageToStorage(image, widget.chatId);

      await _sendMessage(imageUrl, prompt);
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

  Future<void> _sendMessage(String imageUrl, String prompt) async {
    final message = ChatMessage(
      sender: Strings.ai,
      content: imageUrl,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(message);
      _scrollToBottom(); // Scroll to bottom after adding a new message
    });

    await Utilities.sendChatMessage(
      chatId: widget.chatId,
      prompt: prompt,
      ref: ref,
      setLoading: (bool isGenerating) {
        setState(() {
          this.isGenerating = isGenerating;
        });
      },
      imageUrl: imageUrl,
    );
  }

  Future<void> _saveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final image = response.bodyBytes;

        if (image.isNotEmpty) {
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Image',
            fileName: 'uriel${generateChatId()}.png',
          );

          if (outputFile != null) {
            final file = File(outputFile);

            await file.writeAsBytes(image);
            debugPrint('Image saved at: $outputFile');
            if (mounted) {
              CustomSnackBar.showSnackBar(context, 'Image saved successfully.');
            }
          }
        } else {
          throw Exception('Downloaded image is empty');
        }
      } else {
        throw Exception('Failed to download image');
      }
    } catch (error) {
      if (mounted) {
        CustomSnackBar.showSnackBar(context, 'Error saving image: $error');
      }
    }
  }

  Future<void> deleteChat() async {
    final user = ref.read(userProvider);
    if (user != null) {
      final chatId = ref.read(chatProvider(widget.chatId).notifier).chatId;
      await ref
          .read(chatProvider(chatId).notifier)
          .deleteChat(Strings.userImageChats);
      await newChat();
    }
  }

  Future<void> newChat() async {
    setState(() {
      isGenerating = false;
      _messageController.clear();
      messages.clear();
    });

    ref.read(currentChatIdProvider.notifier).state = _newChatId;

    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(chatProvider(widget.chatId).notifier).clearMessages();
      ref.read(chatProvider(widget.chatId).notifier).chatId = _newChatId;
      await ref
          .read(chatProvider(widget.chatId).notifier)
          .loadChat(user.uid, Strings.userImageChats);
    }
  }
}