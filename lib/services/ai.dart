import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../providers/filter_options_provider.dart';
import '../utils/strings.dart';

class AI {
  AI._();

  static final GenerativeModel model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: Strings.apiKey,
    systemInstruction: Content.system(Strings.systemInstructions),
  );

  static Future<String> generateResponse(
    String prompt,
    String chatHistory,
    WidgetRef ref,
  ) async {
    final filterOptions = ref.read(filterOptionsProvider);
    final topic = filterOptions['topic']!;
    final tone = filterOptions['tone']!;
    final mode = filterOptions['mode']!;

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
