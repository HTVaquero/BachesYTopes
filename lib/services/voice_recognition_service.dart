import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/hazard.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> initialize() async {
    return await _speechToText.initialize(
      onError: (error) => debugPrint('Speech recognition error: $error'),
      onStatus: (status) => debugPrint('Speech recognition status: $status'),
    );
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords.toLowerCase());
          }
        },
        listenMode: ListenMode.confirmation,
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  bool get isListening => _isListening;

  bool containsHazardKeyword(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('pothole') || lowerText.contains('speed bump');
  }

  HazardType? detectHazardType(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('pothole')) {
      return HazardType.pothole;
    } else if (lowerText.contains('speed bump')) {
      return HazardType.speedBump;
    }
    return null;
  }
}
