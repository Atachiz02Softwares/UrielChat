import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';

class Utilities {
  static Future<void> sendMessage({
    required String chatId,
    required TextEditingController controller,
    required WidgetRef ref,
    required Function(bool) setLoading,
  }) async {
    if (controller.text.isEmpty) return;

    String prompt = controller.text;

    final message = ChatMessage(
      sender: 'user',
      content: prompt,
      timestamp: DateTime.now(),
    );
    await ref.read(chatProvider(chatId).notifier).addMessage(message);

    setLoading(true);

    final chatHistory = ref
        .read(chatProvider(chatId))
        .map((message) => '${message.sender}: ${message.content}')
        .join('\n');

    try {
      final response = await AI.generateResponse(prompt, chatHistory, ref);
      final aiMessage = ChatMessage(
        sender: 'AI',
        content: response,
        timestamp: DateTime.now(),
      );
      await ref.read(chatProvider(chatId).notifier).addMessage(aiMessage);
    } catch (e) {
      debugPrint('AI Error: $e');
      final errorMessage = ChatMessage(
        sender: 'system',
        content:
            'There was an error processing your request. Please try again later.',
        timestamp: DateTime.now(),
      );
      await ref.read(chatProvider(chatId).notifier).addMessage(errorMessage);
    } finally {
      setLoading(false);
      controller.clear();
    }
  }

  static void showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.black,
      context: context,
      builder: (context) {
        return FeedbackBottomSheet();
      },
    );
  }

  static void showInfo(BuildContext context, String title, String content) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.black,
      context: context,
      builder: (context) {
        return InfoBottomSheet(title: title, content: content);
      },
    );

  }
}
