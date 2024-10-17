import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../providers/filter_options_provider.dart';
import '../utils/strings.dart';

class AI {
  AI._();

  static Future<GenerativeModel> _getModel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      throw Exception('User data not found');
    }

    final userData = userSnapshot.data();
    String tier = userData?['tier'] ?? 'free';

    String model;
    String apiKey;

    model = tier == 'free' ? Strings.freeModel : Strings.paidModel;
    apiKey = tier == 'free' ? Strings.freeAPIKey : Strings.paidAPIKey;

    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: Content.system(Strings.systemInstructions),
    );
  }

  static Future<String> generateResponse(
    String prompt,
    String chatHistory,
    WidgetRef ref,
  ) async {
    final filterOptions = ref.read(filterOptionsProvider);
    final topic = filterOptions['topic']!;
    final tone = filterOptions['tone']!;
    final mode = filterOptions['mode']!;

    final model = await _getModel();

    final response = await model.generateContent([
      Content.text('Chat History: $chatHistory'),
      Content.text('Topic: $topic'),
      Content.text('Tone: $tone'),
      Content.text('Mode: $mode'),
      Content.text('PROMPT: $prompt'),
    ]);

    return response.text!;
  }
}
