import 'dart:io' show Platform, File;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:stability_image_generation/stability_image_generation.dart';
import 'package:uriel_chat/providers/chat_provider.dart';
import 'package:uriel_chat/providers/providers.dart';

import '../custom_widgets/custom.dart';
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
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // final StabilityAI _ai = StabilityAI();
  final String apiKey = Strings.stabilityAPIKey;
  final ImageAIStyle imageAIStyle = ImageAIStyle.render3D;
  bool isGenerating = false;

  List<Map<String, dynamic>> messages = [];

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
        onNewChat: () {
          setState(() {
            messages.clear();
          });
        },
        onDeleteChat: () {
          setState(() {
            messages.clear();
          });
        },
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
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final timestamp = message["timestamp"];
                            if (message["type"] == "user") {
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
                                          text: message["content"],
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
                                              text: formatDateTime(timestamp),
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
                                                    text: message["content"]));
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
                                            message["content"],
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
                                              text: formatDateTime(timestamp),
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
                                                _saveImage(message["content"]);
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
                  isLoading: isGenerating,
                  onSendMessage: () {
                    final query = _messageController.text;
                    if (query.isNotEmpty && !isGenerating) {
                      _generateImage(query);
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

  Future<void> _generateImage(String query) async {
    setState(() {
      isGenerating = true;
      // Add the user's message to the messages list
      messages.add({
        "type": "user",
        "content": query,
        "timestamp": DateTime.now().toIso8601String(),
      });
    });

    try {
      // Generate the image
      img.Image baseImage = img.Image(width: 2, height: 2);
      baseImage.setPixel(0, 0, img.ColorInt32.rgba(255, 0, 0, 255));
      baseImage.setPixel(1, 0, img.ColorInt32.rgba(0, 255, 0, 255));
      baseImage.setPixel(0, 1, img.ColorInt32.rgba(0, 0, 255, 255));
      baseImage.setPixel(1, 1, img.ColorInt32.rgba(255, 255, 0, 255));
      Uint8List image = Uint8List.fromList(img.encodePng(baseImage));

      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImageToStorage(image);

      // Call the _sendMessage method with the image URL
      await _sendMessage(imageUrl);
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

  Future<void> _sendMessage(String imageUrl) async {
    final message = {
      "type": "ai",
      "content": imageUrl,
      "timestamp": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(message);
    });

    await Utilities.sendChatMessage(
      chatId: widget.chatId,
      controller: _messageController,
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

  Future<void> _saveImage(String imageUrl) async {
    try {
      // Download the image data
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final image = response.bodyBytes;

        if (image.isNotEmpty) {
          // Open file save dialog
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Image',
            fileName: 'uriel${generateChatId()}.png',
          );

          if (outputFile != null) {
            final file = File(outputFile);

            // Write image data to file
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

  String formatDateTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('hh:mm a').format(dateTime);
  }
}
