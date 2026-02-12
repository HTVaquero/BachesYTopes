import 'package:flutter_tts/flutter_tts.dart';
import '../models/hazard.dart';

class NotificationService {
  final FlutterTts _flutterTts = FlutterTts();
  final Set<String> _notifiedHazards = {};

  NotificationService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> checkAndNotifyHazards(
    List<Hazard> hazards,
    double currentLat,
    double currentLon,
    double speedMps,
  ) async {
    const double notificationDistance = 100.0; // meters
    
    for (final hazard in hazards) {
      final distance = hazard.distanceFrom(currentLat, currentLon);
      
      if (distance <= notificationDistance && !_notifiedHazards.contains(hazard.id)) {
        await _notifyHazard(hazard, distance, speedMps);
        _notifiedHazards.add(hazard.id);
      } else if (distance > notificationDistance) {
        _notifiedHazards.remove(hazard.id);
      }
    }
  }

  Future<void> _notifyHazard(Hazard hazard, double distance, double speedMps) async {
    final hazardName = hazard.type == HazardType.pothole ? "pothole" : "speed bump";
    final distanceRounded = distance.round();
    
    String message;
    if (speedMps > 5) {
      message = "Caution! $hazardName ahead in $distanceRounded meters";
    } else {
      message = "$hazardName nearby, $distanceRounded meters ahead";
    }
    
    await _flutterTts.speak(message);
  }

  void clearNotifications() {
    _notifiedHazards.clear();
  }
}
