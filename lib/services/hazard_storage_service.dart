import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hazard.dart';

class HazardStorageService {
  static const String _hazardsKey = 'hazards';

  Future<List<Hazard>> getAllHazards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? hazardsJson = prefs.getString(_hazardsKey);
    if (hazardsJson == null) return [];

    final List<dynamic> decoded = json.decode(hazardsJson);
    return decoded.map((json) => Hazard.fromJson(json)).toList();
  }

  Future<void> addHazard(Hazard hazard) async {
    final hazards = await getAllHazards();
    hazards.add(hazard);
    await _saveHazards(hazards);
  }

  Future<void> _saveHazards(List<Hazard> hazards) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(hazards.map((h) => h.toJson()).toList());
    await prefs.setString(_hazardsKey, encoded);
  }

  Future<List<Hazard>> getNearbyHazards(
      double latitude, double longitude, double radiusMeters) async {
    final allHazards = await getAllHazards();
    return allHazards
        .where((h) => h.distanceFrom(latitude, longitude) <= radiusMeters)
        .toList();
  }
}
