import 'dart:io' show Platform;

import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

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
  Map<String, bool> isDownloadingMap = {};
  Map<String, double> downloadProgressMap = {};
  bool isGenerating = false, isDownloading = false;
  double downloadProgress = 0.0;

  final StabilityAI _ai = StabilityAI();
  final String apiKey = Strings.stabilityAPIKey;
  final ImageAIStyle imageAIStyle = ImageAIStyle.noStyle;

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
    final chatService = ref.read(chatServiceProvider);
    final messages = await chatService
        .getMessages(widget.chatId, Strings.userImageChats)
        .first;
    setState(() {
      this.messages = messages;
    });
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
        iconSize = MediaQuery.of(context).size.width * 0.07,
        icSize = MediaQuery.of(context).size.width * 0.05;

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
                                                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                                                width: icSize,
                                                height: icSize,
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
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(borderRadius: BorderRadius.circular(15),
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
                                              text: Strings.formatDateTime(message.timestamp.toIso8601String()),
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            IconButton(
                                              tooltip: 'Save Image',
                                              icon: isDownloadingMap[message.content] == true
                                                  ? CustomProgressBar(value: downloadProgressMap[message.content] ?? 0.0, size: icSize)
                                                  : SvgPicture.asset(
                                                Strings.download,
                                                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                                                width: icSize,
                                                height: icSize,
                                              ),
                                              onPressed: isDownloadingMap[message.content] == true
                                                  ? null
                                                  : () async {
                                                final status = await Utilities.requestPermission(Permission.storage);
                                                if (status) await _saveImage(message.content);
                                                else if (context.mounted){
                                                  CustomSnackBar.showSnackBar(
                                                      context,
                                                      'Storage permission denied...',
                                                      isError: true,
                                                  );
                                                }
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
                  onSendMessage: () async {
                    final canGenerate = await Utilities.checkDailyImageLimit(ref);
                    if (!canGenerate && context.mounted) {
                      Utilities.showRateLimitBottomSheet(context);
                      return;
                    } else {
                      final prompt = _messageController.text;
                      _messageController.clear();
                      if (prompt.isNotEmpty && !isGenerating) {
                        _generateImage(prompt);
                      }
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
      /// Sample image generation using the image package for debugging
      img.Image baseImage = img.Image(width: 2, height: 2);
      baseImage.setPixel(0, 0, img.ColorInt32.rgba(255, 0, 0, 255));
      baseImage.setPixel(1, 0, img.ColorInt32.rgba(0, 255, 0, 255));
      baseImage.setPixel(0, 1, img.ColorInt32.rgba(0, 0, 255, 255));
      baseImage.setPixel(1, 1, img.ColorInt32.rgba(255, 255, 0, 255));
      Uint8List image = Uint8List.fromList(img.encodePng(baseImage));

      // Uint8List image = await _ai.generateImage(
      //   apiKey: apiKey,
      //   imageAIStyle: imageAIStyle,
      //   prompt: prompt,
      // );

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
      _scrollToBottom();
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
    setState(() {
      isDownloadingMap[imageUrl] = true;
      downloadProgressMap[imageUrl] = 0.0;
    });

    try {
      final Dio dio = Dio();
      final Response response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          setState(() {
            downloadProgressMap[imageUrl] = (received / total);
          });
        },
      );

      if (response.statusCode == 200) {
        final Uint8List imageData = Uint8List.fromList(response.data);
        final result = await ImageGallerySaverPlus.saveImage(
          imageData,
          quality: 100,
          name: 'uriel${generateChatId()}',
        );

        setState(() {
          isDownloadingMap[imageUrl] = false;
          downloadProgressMap[imageUrl] = 0.0;
        });

        if (result['isSuccess'] && mounted) {
          CustomSnackBar.showSnackBar(
            context,
            'Image saved to gallery at ${result['filePath']}',
          );
        } else if (mounted) {
          CustomSnackBar.showSnackBar(
            context,
            'Failed to save image to gallery.',
            isError: true,
          );
        }
      } else if (mounted) {
        CustomSnackBar.showSnackBar(
          context,
          'Image download failed.',
          isError: true,
        );
      }
    } catch (error) {
      setState(() {
        isDownloadingMap[imageUrl] = false;
        downloadProgressMap[imageUrl] = 0.0;
      });
      if (mounted) {
        CustomSnackBar.showSnackBar(
          context,
          'Error saving image: $error',
          isError: true,
        );
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
