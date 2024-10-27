import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../custom_widgets/custom.dart';
import '../firebase/crud.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/strings.dart';

class Utilities {
  static Future<void> initializeRemoteConfig(WidgetRef ref) async {
    final remoteConfigService = ref.read(remoteConfigProvider);
    Strings.freeModel = remoteConfigService.freeModel;
    Strings.paidModel = remoteConfigService.paidModel;
    Strings.freeAPIKey = remoteConfigService.freeAPIKey;
    Strings.paidAPIKey = remoteConfigService.paidAPIKey;
    Strings.stabilityAPIKey = remoteConfigService.stabilityAPIKey;
    Strings.payStackPublicKey = remoteConfigService.payStackPublicKey;
    Strings.payStackSecretKey = remoteConfigService.payStackSecretKey;
    Strings.free = remoteConfigService.free;
    Strings.regular = remoteConfigService.regular;
    Strings.regularMoney = remoteConfigService.regularMoney;
    Strings.premium = remoteConfigService.premium;
    Strings.premiumMoney = remoteConfigService.premiumMoney;
    Strings.platinum = remoteConfigService.platinum;
    Strings.platinumMoney = remoteConfigService.platinumMoney;
    Strings.mediaPlans = remoteConfigService.mediaPlans;
  }

  static Future<void> sendChatMessage({
    required String chatId,
    required TextEditingController controller,
    required WidgetRef ref,
    required Function(bool) setLoading,
    String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
    FirebaseFirestore.instance.collection(Strings.users).doc(user.uid);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) return;

    final userData = userSnapshot.data();
    String tier = userData?['tier'] ?? 'free';
    int dailyCount = userData?['dailyCount'] ?? 0;
    int dailyLimit = userData?['dailyLimit'] ?? (tier == 'free' ? 30 : 50);
    Timestamp lastChatTime = userData?['lastChatTime'] ?? Timestamp.now();

    DateTime now = DateTime.now();
    DateTime lastResetDate = lastChatTime.toDate();

    // Check if a new day has started
    if (now.difference(lastResetDate).inHours >= 24) {
      await userDoc.update({'dailyCount': 0});
      dailyCount = 0;
    }

    if (dailyCount >= dailyLimit && ref.context.mounted) {
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
    await ref
        .read(chatProvider(chatId).notifier)
        .addMessage(message, imageUrl == null ? Strings.userChats : Strings.userImageChats);

    setLoading(true);

    try {
      CRUD().resetSubIfExpired(now); // Reset user subscription if expired

      await userDoc.update({
        'dailyCount': FieldValue.increment(1),
        'lastChatTime': Timestamp.now()
      });

      if (imageUrl == null) {
        final chatHistory = ref
            .read(chatProvider(chatId))
            .map((message) => '${message.sender}: ${message.content}')
            .join('\n');

        final response = await AI.generateResponse(prompt, chatHistory, ref);
        final aiMessage = ChatMessage(
          sender: 'AI',
          content: response,
          timestamp: DateTime.now(),
        );
        await ref
            .read(chatProvider(chatId).notifier)
            .addMessage(aiMessage, Strings.userChats);
      } else {
        final aiMessage = ChatMessage(
          sender: 'AI',
          content: imageUrl,
          timestamp: DateTime.now(),
        );
        await ref
            .read(chatProvider(chatId).notifier)
            .addMessage(aiMessage, Strings.userImageChats);
      }
    } catch (e) {
      if (kDebugMode) Logger().e('AI Error: $e');
      final errorMessage = ChatMessage(
        sender: 'system',
        content:
        'There was an error processing your request. Please try again later.',
        timestamp: DateTime.now(),
      );
      await ref
          .read(chatProvider(chatId).notifier)
          .addMessage(errorMessage, imageUrl == null ? Strings.userChats : Strings.userImageChats);
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

  static void promptUpgrade(BuildContext context) {
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
              Navigator.of(context).pushReplacementNamed('/paystack');
            },
          ),
        );
      },
    );
  }

  static Future<String> fetchCurrentPlan(WidgetRef ref) async {
    final user = ref.read(userProvider);
    if (user != null) {
      return await CRUD().fetchCurrentPlan(user.uid);
    }
    return 'free';
  }
}
