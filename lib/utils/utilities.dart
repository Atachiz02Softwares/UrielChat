import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uriel_chat/utils/strings.dart';

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

    // Fetch the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch user data from Firestore
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();

    // Check if the user data exists
    if (!userSnapshot.exists) return;

    // Get the daily limit and count
    final userData = userSnapshot.data();
    String tier = userData?['tier'] ?? 'free';
    int dailyCount = userData?['dailyCount'] ?? 0;
    int dailyLimit = userData?['dailyLimit'] ?? (tier == 'free' ? 30 : 50);

    // Check if the user has reached their daily message limit
    if (dailyCount >= dailyLimit && ref.context.mounted) {
      // Show upgrade prompt
      promptUpgrade(ref.context);
      return;
    }

    // If not reached, proceed to send message and increment daily count
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
      // Increment the daily count in Firestore
      await userDoc.update({'dailyCount': FieldValue.increment(1)});

      // Generate AI response
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
      controller.clear(); // Clear the controller after saving the message
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

  static void promptUpgrade(
    BuildContext context,
  ) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.black,
      context: context,
      builder: (context) {
        return InfoBottomSheet(
          title: '**Upgrade Required**',
          content: Strings.upgradePrompt,
          button: CustomButton(
            icon: Strings.dollar,
            label: 'Upgrade Now',
            buttonColor: Colors.green.shade900,
            iconColor: false,
            onPressed: () {
              // TODO: Perform upgrade action
              Navigator.of(context).pop();
              CustomSnackBar.showSnackBar(
                context,
                'Upgrade action not implemented yet...',
              );
            },
          ),
        );
      },
    );
  }
}
