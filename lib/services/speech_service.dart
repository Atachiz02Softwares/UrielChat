import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../custom_widgets/custom.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<bool> _isListeningController =
      StreamController<bool>.broadcast();

  Stream<bool> get isListeningStream => _isListeningController.stream;

  Future<void> listen(
      BuildContext context, Function(String) onResultCallback) async {
    if (_speech.isListening) return;

    await requestMicPermission(context);

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListeningController.add(false);
        }
        if (kDebugMode) Logger().d('Speech status: $status');
      },
      onError: (error) {
        _isListeningController.add(false);
        if (kDebugMode) Logger().e('Speech error: $error');
      },
      debugLogging: true,
    );

    if (!available && context.mounted) {
      CustomSnackBar.showSnackBar(
          context, 'Speech recognition is not available...');
      return;
    }

    _isListeningController.add(true);

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.hasConfidenceRating && result.confidence > 0) {
          onResultCallback(result.recognizedWords);
          if (kDebugMode) {
            Logger().d('Confidence: ${result.confidence}');
            Logger().d('Recognized: ${result.recognizedWords}');
          }
        } else if (kDebugMode) {
          Logger().d('No confidence rating available...');
        }
      },
      listenFor: const Duration(minutes: 2), // Extend listening time
      pauseFor: const Duration(seconds: 10), // Allow 10 seconds of silence
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation, // Dictation mode for longer input
      ),
    );
  }

  void stop() {
    if (_speech.isListening) {
      _speech.stop();
      _isListeningController.add(false);
    }
  }

  Future<void> requestMicPermission(BuildContext context) async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      var result = await Permission.microphone.request();
      if (!result.isGranted && context.mounted) {
        CustomSnackBar.showSnackBar(context, 'Microphone permission denied...');
        return;
      }
    }
  }

  void dispose() {
    _isListeningController.close();
  }
}
