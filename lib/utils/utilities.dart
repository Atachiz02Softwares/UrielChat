import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/models.dart';
import '../providers/providers.dart'; // Ensure this import is present
import '../services/services.dart';

class Utilities {
  static Future<void> sendMessage({
    required String chatId,
    required TextEditingController controller,
    required WidgetRef ref,
    required Function(bool) setLoading,
    required Function(int) incrementResponseCount,
    required String selectedTopic,
    required String selectedTone,
    required String selectedMode,
  }) async {
    if (controller.text.isEmpty) return;

    final message = ChatMessage(
      sender: 'user',
      content: controller.text,
      timestamp: DateTime.now(),
    );
    await ref.read(chatProvider(chatId).notifier).addMessage(message);

    setLoading(true);

    final chatHistoryString = ref
        .read(chatProvider(chatId))
        .map((message) => '${message.sender}: ${message.content}')
        .join('\n');

    final prompt = '''
Based on the following chat history, limit responses to the topic of $selectedTopic.
Respond with a $selectedTone tone and focus on a $selectedMode mode of conversation.
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
    }
  }
}
