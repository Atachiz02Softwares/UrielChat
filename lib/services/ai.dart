import 'package:google_generative_ai/google_generative_ai.dart';

import '../utils/strings.dart';

class AI {
  AI._();

  static final GenerativeModel model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: Strings.apiKey,
    systemInstruction: Content.system(Strings.systemInstructions),
  );
}
