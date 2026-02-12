import 'package:flutter_test/flutter_test.dart';
import 'package:baches_y_topes/models/hazard.dart';

void main() {
  group('Hazard Model Tests', () {
    test('Hazard serialization to JSON', () {
      final hazard = Hazard(
        id: '123',
        type: HazardType.pothole,
        latitude: 40.7128,
        longitude: -74.0060,
        reportedAt: DateTime(2024, 1, 1),
        reportedBy: 'testuser',
      );

      final json = hazard.toJson();

      expect(json['id'], '123');
      expect(json['type'], 'pothole');
      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
      expect(json['reportedBy'], 'testuser');
    });

    test('Hazard deserialization from JSON', () {
      final json = {
        'id': '456',
        'type': 'speedBump',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'reportedAt': '2024-01-01T00:00:00.000',
        'reportedBy': 'anotheruser',
      };

      final hazard = Hazard.fromJson(json);

      expect(hazard.id, '456');
      expect(hazard.type, HazardType.speedBump);
      expect(hazard.latitude, 34.0522);
      expect(hazard.longitude, -118.2437);
      expect(hazard.reportedBy, 'anotheruser');
    });

    test('Distance calculation between two points', () {
      final hazard = Hazard(
        id: '789',
        type: HazardType.pothole,
        latitude: 40.7128,
        longitude: -74.0060,
        reportedAt: DateTime.now(),
        reportedBy: 'user',
      );

      // Nearby location (approximately 1km away)
      final distance = hazard.distanceFrom(40.7228, -74.0060);

      // Distance should be roughly 1100 meters (allowing for calculation variance)
      expect(distance, greaterThan(800));
      expect(distance, lessThan(1400));
    });

    test('Distance to same location should be near zero', () {
      final hazard = Hazard(
        id: '999',
        type: HazardType.speedBump,
        latitude: 40.7128,
        longitude: -74.0060,
        reportedAt: DateTime.now(),
        reportedBy: 'user',
      );

      final distance = hazard.distanceFrom(40.7128, -74.0060);

      expect(distance, lessThan(1)); // Should be very close to 0
    });
  });
}
