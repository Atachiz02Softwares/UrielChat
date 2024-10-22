import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final speechService = SpeechService();
  ref.onDispose(() => speechService.dispose());
  return speechService;
});
