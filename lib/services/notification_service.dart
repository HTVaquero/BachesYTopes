import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/hazard.dart';

class NotificationService {
  final FlutterTts _flutterTts = FlutterTts();
  final Set<String> _notifiedHazards = {};

  NotificationService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("es-MX");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> checkAndNotifyHazards(
    List<Hazard> hazards,
    double currentLat,
    double currentLon,
    double speedMps,
    double headingDegrees,
  ) async {
    const double minSpeedMps = 5.0; // ~18 kph minimum - ignore stationary/slow movement
    const double maxHeadingDelta = 35.0; // degrees cone

    if (speedMps < minSpeedMps) {
      _notifiedHazards.clear();
      return;
    }

    if (headingDegrees.isNaN) {
      return;
    }

    // Dynamic notification distance based on speed
    // At 2.5 m/s (9 kph): 80m warning, at 30 m/s (108 kph): 150m warning
    final speedKmh = speedMps * 3.6;
    double notificationDistance = 80.0 + (speedKmh - 9.0) * 2.0;
    notificationDistance = notificationDistance.clamp(80.0, 150.0);
    
    for (final hazard in hazards) {
      final distance = hazard.distanceFrom(currentLat, currentLon);
      
      final bearing = _bearingDegrees(
        currentLat,
        currentLon,
        hazard.latitude,
        hazard.longitude,
      );
      final delta = _angularDelta(headingDegrees, bearing);

      if (distance <= notificationDistance &&
          delta <= maxHeadingDelta &&
          !_notifiedHazards.contains(hazard.id)) {
        await _notifyHazard(hazard, distance, speedMps);
        _notifiedHazards.add(hazard.id);
      } else if (distance > notificationDistance + 30) {
        // Add 30m buffer to prevent rapid re-triggering
        _notifiedHazards.remove(hazard.id);
      }
    }
  }

  double _bearingDegrees(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    final dLon = _toRadians(lon2 - lon1);

    final y = sin(dLon) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(dLon);
    final theta = atan2(y, x);
    return (_toDegrees(theta) + 360) % 360;
  }

  double _angularDelta(double a, double b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
  double _toDegrees(double radians) => radians * 180 / pi;

  Future<void> _notifyHazard(Hazard hazard, double distance, double speedMps) async {
    final hazardName = hazard.type == HazardType.pothole ? "bache" : "tope";
    final distanceRounded = distance.round();
    
    String message;
    if (speedMps > 5) {
      message = "Precaucion! $hazardName adelante en $distanceRounded metros";
    } else {
      message = "$hazardName cerca, $distanceRounded metros adelante";
    }
    
    await _flutterTts.speak(message);
  }

  void clearNotifications() {
    _notifiedHazards.clear();
  }
}
