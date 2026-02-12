import 'dart:math';

class Hazard {
  final String id;
  final HazardType type;
  final double latitude;
  final double longitude;
  final DateTime reportedAt;
  final String reportedBy;

  Hazard({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.reportedAt,
    required this.reportedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'reportedAt': reportedAt.toIso8601String(),
      'reportedBy': reportedBy,
    };
  }

  factory Hazard.fromJson(Map<String, dynamic> json) {
    return Hazard(
      id: json['id'],
      type: HazardType.values.firstWhere((e) => e.name == json['type']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      reportedAt: DateTime.parse(json['reportedAt']),
      reportedBy: json['reportedBy'],
    );
  }

  double distanceFrom(double lat, double lon) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(latitude - lat);
    final dLon = _toRadians(longitude - lon);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat)) *
            cos(_toRadians(latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

enum HazardType {
  pothole,
  speedBump,
}
