import 'dart:math';

class Hazard {
  final String id;
  final HazardType type;
  final double latitude;
  final double longitude;
  final DateTime reportedAt;
  final String reportedBy;
  final String description;

  Hazard({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.reportedAt,
    this.reportedBy = 'user',
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'reportedAt': reportedAt.toIso8601String(),
      'reportedBy': reportedBy,
      'description': description,
    };
  }

  factory Hazard.fromJson(Map<String, dynamic> json) {
    final rawDate = json['reportedAt'] ?? json['created_at'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
    final rawType = (json['type'] ?? '').toString().toLowerCase();
    final normalizedType = rawType.replaceAll(' ', '_');
    final hazardType = normalizedType == 'speed_bump' || normalizedType == 'speedbump'
        ? HazardType.speedBump
        : HazardType.pothole;

    return Hazard(
      id: json['id'].toString(),
      type: hazardType,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      reportedAt: parsedDate ?? DateTime.now(),
      reportedBy: (json['reportedBy'] ?? 'api').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  factory Hazard.fromApiJson(Map<String, dynamic> json) {
    return Hazard.fromJson(json);
  }

  Map<String, dynamic> toApiJson() {
    final apiType = type == HazardType.speedBump ? 'speed_bump' : 'pothole';
    return {
      'type': apiType,
      'description': description.isEmpty ? 'Reporte desde la app' : description,
      'latitude': latitude,
      'longitude': longitude,
    };
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
