import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hazard.dart';

class HazardApiService {
  static const String _baseUrl = 'http://140.84.176.123:3000/api';
  final http.Client _client;

  HazardApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Hazard>> fetchHazards() async {
    final uri = Uri.parse('$_baseUrl/hazards');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch hazards: ${response.statusCode}');
    }

    final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Hazard.fromApiJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Hazard> createHazard(Hazard hazard) async {
    final uri = Uri.parse('$_baseUrl/hazards');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(hazard.toApiJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      throw Exception('Failed to create hazard: ${response.statusCode}');
    }

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;
    return Hazard.fromApiJson(decoded);
  }
}
