import 'package:flutter_test/flutter_test.dart';
import 'package:baches_y_topes/models/hazard.dart';
import 'package:baches_y_topes/services/voice_recognition_service.dart';

void main() {
  group('Voice Recognition Service Tests', () {
    late VoiceRecognitionService voiceService;

    setUp(() {
      voiceService = VoiceRecognitionService();
    });

    test('Detect bache keyword in text', () {
      final result = voiceService.containsHazardKeyword('Encontre un bache');
      expect(result, isTrue);
    });

    test('Detect tope keyword in text', () {
      final result = voiceService.containsHazardKeyword('Hay un tope adelante');
      expect(result, isTrue);
    });

    test('Return false for text without hazard keywords', () {
      final result = voiceService.containsHazardKeyword('The weather is nice');
      expect(result, isFalse);
    });

    test('Case insensitive keyword detection', () {
      final result = voiceService.containsHazardKeyword('BACHE');
      expect(result, isTrue);
    });

    test('Detect bache hazard type', () {
      final result = voiceService.detectHazardType('Encontre un bache');
      expect(result, HazardType.pothole);
    });

    test('Detect tope hazard type', () {
      final result = voiceService.detectHazardType('Hay un tope');
      expect(result, HazardType.speedBump);
    });

    test('Return null for unknown hazard type', () {
      final result = voiceService.detectHazardType('random text');
      expect(result, isNull);
    });

    test('Initially not listening', () {
      expect(voiceService.isListening, isFalse);
    });

    test('Multiple bache detections', () {
      final text = 'Encontre un bache y otro bache';
      final result = voiceService.detectHazardType(text);
      expect(result, HazardType.pothole);
    });

    test('Prefer bache when both keywords present', () {
      final text = 'bache cerca de un tope';
      final result = voiceService.detectHazardType(text);
      expect(result, HazardType.pothole); // bache is checked first
    });
  });
}
