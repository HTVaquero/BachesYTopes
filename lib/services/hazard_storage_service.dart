import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hazard.dart';
import './hazard_api_service.dart';

class HazardStorageService {
  static const String _hazardsKey = 'hazards';
  final HazardApiService _apiService = HazardApiService();
  bool _lastFetchOk = true;

  bool get lastFetchOk => _lastFetchOk;

  Future<List<Hazard>> getAllHazards() async {
    try {
      final hazards = await _apiService.fetchHazards();
      _lastFetchOk = true;
      await _saveHazards(hazards);
      return hazards;
    } catch (_) {
      _lastFetchOk = false;
      return _getCachedHazards();
    }
  }

  Future<void> addHazard(Hazard hazard) async {
    try {
      final created = await _apiService.createHazard(hazard);
      final hazards = await _getCachedHazards();
      hazards.insert(0, created);
      await _saveHazards(hazards);
    } catch (_) {
      final hazards = await _getCachedHazards();
      hazards.add(hazard);
      await _saveHazards(hazards);
    }
  }

  Future<List<Hazard>> _getCachedHazards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? hazardsJson = prefs.getString(_hazardsKey);
    if (hazardsJson == null) return [];

    final List<dynamic> decoded = json.decode(hazardsJson);
    return decoded.map((json) => Hazard.fromJson(json)).toList();
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
