import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hazard.dart';
import '../services/hazard_storage_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/voice_recognition_service.dart';
import '../widgets/quick_report_widget.dart';
import '../widgets/voice_listening_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final HazardStorageService _storageService = HazardStorageService();
  final NotificationService _notificationService = NotificationService();
  final VoiceRecognitionService _voiceService = VoiceRecognitionService();

  static const String _deviceIdKey = 'device_id';
  static const String _reportTimesKey = 'report_timestamps';
  static const String _confirmationsKey = 'hazard_confirmations';
  static const String _confirmedKey = 'hazard_confirmed_ids';
  static const String _privacyNoticeKey = 'privacy_notice_shown';
  static const String _reportWarningShownKey = 'report_warning_shown';
  static const String _voiceEnabledKey = 'voice_reporting_enabled';
  static const String _driverModeKey = 'driver_mode_selected';

  Position? _currentPosition;
  List<Hazard> _hazards = [];
  List<Marker> _markers = [];
  StreamSubscription<Position>? _positionSubscription;
  Timer? _notificationTimer;
  Timer? _refreshTimer;

  bool _isListening = false;
  bool _isLocating = true;
  String? _locationError;
  bool _mapReady = false;
  bool _followUser = true;
  bool _apiErrorShown = false;
  bool _voiceEnabled = true;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _bootstrapStartup();
  }

  Future<void> _bootstrapStartup() async {
    await _loadPreferences();
    await _showPrivacyNoticeIfNeeded();
    await _initializeServices();
    await _showDriverPassengerChoice();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _voiceEnabled = prefs.getBool(_voiceEnabledKey) ?? true;
      _isDriver = prefs.getBool(_driverModeKey) ?? false;
    });
  }

  Future<void> _initializeServices() async {
    _positionSubscription?.cancel();
    _notificationTimer?.cancel();

    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    final hasLocation = await _locationService.requestPermission();
    await _voiceService.requestPermission();
    await _voiceService.initialize();

    if (!hasLocation) {
      setState(() {
        _isLocating = false;
        _locationError = 'Permiso de ubicacion denegado o servicios desactivados.';
      });
      return;
    }

    final initialPosition = await _locationService.getCurrentPosition() ??
        await _locationService.getLastKnownPosition();

    if (initialPosition != null) {
      setState(() {
        _currentPosition = initialPosition;
        _isLocating = false;
      });
      _updateCameraPosition(initialPosition);
    } else {
      setState(() {
        _isLocating = false;
        _locationError = 'No se pudo determinar la ubicacion actual.';
      });
    }

    _loadHazards();
    _startLocationTracking();
    _startNotificationChecking();
    _startHazardRefresh();
  }

  Future<void> _loadHazards() async {
    final hazards = await _storageService.getAllHazards();
    setState(() {
      _hazards = hazards;
      _updateMarkers();
    });

    if (!_storageService.lastFetchOk && !_apiErrorShown) {
      _apiErrorShown = true;
      _showMessage('No se pudieron cargar reportes del servidor.');
    }
  }

  void _startLocationTracking() {
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        setState(() {
          _currentPosition = position;
          _isLocating = false;
          _locationError = null;
          _updateCameraPosition(position);
        });
      },
      onError: (_) {
        setState(() {
          _isLocating = false;
          _locationError = 'No se pudo acceder a las actualizaciones de ubicacion.';
        });
      },
    );
  }

  void _startNotificationChecking() {
    _notificationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentPosition != null) {
        _checkNearbyHazards();
      }
    });
  }

  void _startHazardRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadHazards();
    });
  }

  Future<void> _checkNearbyHazards() async {
    if (_currentPosition == null) return;
    
    final nearbyHazards = await _storageService.getNearbyHazards(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      500, // 500 meters radius
    );

    await _notificationService.checkAndNotifyHazards(
      nearbyHazards,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _currentPosition!.speed,
      _currentPosition!.heading,
    );
  }

  void _updateCameraPosition(Position position) {
    if (!_mapReady || !_followUser) {
      return;
    }
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      18.0,
    );
  }

  void _centerOnUser() {
    if (_currentPosition == null) {
      _showMessage('Ubicacion no disponible');
      return;
    }
    setState(() {
      _followUser = true;
    });
    _mapController.move(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      18.0,
    );
  }

  void _updateMarkers() {
    _markers = _hazards.map((hazard) {
      final isPothole = hazard.type == HazardType.pothole;
      final backgroundColor = isPothole ? Colors.red : Colors.white;
      final iconColor = isPothole ? Colors.black : Colors.red;
      return Marker(
        point: LatLng(hazard.latitude, hazard.longitude),
        child: GestureDetector(
          onTap: () {
            _showHazardInfo(hazard);
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.warning_amber,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildMapMarkers() {
    final markers = List<Marker>.from(_markers);
    if (_currentPosition != null) {
      final heading = _currentPosition!.heading.isNaN
          ? 0.0
          : _currentPosition!.heading;
      final radians = heading * pi / 180;
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: Transform.rotate(
            angle: radians,
            child: const Icon(
              Icons.navigation,
              color: Colors.green,
              size: 34,
            ),
          ),
        ),
      );
    }
    return markers;
  }

  void _showHazardInfo(Hazard hazard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          hazard.type == HazardType.pothole ? 'Bache' : 'Tope',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lat: ${hazard.latitude.toStringAsFixed(4)}'),
            Text('Lon: ${hazard.longitude.toStringAsFixed(4)}'),
            Text('Reportado: ${hazard.reportedAt.toString().substring(0, 16)}'),
            FutureBuilder<int>(
              future: _getLocalConfirmationCount(hazard.id),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Text('Confirmaciones locales: $count');
              },
            ),
            if (hazard.description.isNotEmpty)
              Text('Detalle: ${hazard.description}'),
          ],
        ),
        actions: [
          FutureBuilder<bool>(
            future: _hasConfirmedHazard(hazard.id),
            builder: (context, snapshot) {
              final alreadyConfirmed = snapshot.data ?? false;
              return TextButton(
                onPressed: alreadyConfirmed
                    ? null
                    : () async {
                        await _confirmHazard(hazard.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        _showMessage('Gracias por confirmar.');
                      },
                child: Text(alreadyConfirmed ? 'Confirmado' : 'Confirmar'),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final newId = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  Future<void> _showPrivacyNoticeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(_privacyNoticeKey) ?? false;
    
    if (!hasShown && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sobre la privacidad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¿Qué información se recopila?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Esta app solo recopila:',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '• Tu ubicación GPS - utilizada únicamente para registrar las coordenadas correctas de los reportes de baches y topes.',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '• Tipo de reportes (bache o tope)',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '• Descripción del reporte',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 16),
                Text(
                  '¿Qué NO se recopila?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '✓ Sin información personal',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '✓ Sin ID de dispositivo o identificadores únicos',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '✓ Sin seguimiento de comportamiento',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '✓ Sin análisis o estadísticas de usuario',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 16),
                Text(
                  'Todos los reportes se envían de forma anónima. Tu privacidad es importante para nosotros.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await prefs.setBool(_privacyNoticeKey, true);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  Future<List<DateTime>> _getRecentReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_reportTimesKey) ?? [];
    final now = DateTime.now();
    final parsed = raw
        .map((item) => DateTime.tryParse(item))
        .whereType<DateTime>()
        .where((time) => now.difference(time) <= const Duration(hours: 1))
        .toList();
    await prefs.setStringList(
      _reportTimesKey,
      parsed.map((time) => time.toIso8601String()).toList(),
    );
    return parsed;
  }

  Future<void> _storeReportTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getRecentReports();
    list.add(DateTime.now());
    await prefs.setStringList(
      _reportTimesKey,
      list.map((time) => time.toIso8601String()).toList(),
    );
  }

  Future<int> _getLocalConfirmationCount(String hazardId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_confirmationsKey);
    if (raw == null || raw.isEmpty) return 0;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded[hazardId] as num?)?.toInt() ?? 0;
  }

  Future<bool> _hasConfirmedHazard(String hazardId) async {
    final prefs = await SharedPreferences.getInstance();
    final confirmed = prefs.getStringList(_confirmedKey) ?? [];
    return confirmed.contains(hazardId);
  }

  Future<List<String>> _getConfirmedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_confirmedKey) ?? [];
  }

  Future<void> _confirmHazard(String hazardId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_confirmationsKey);
    final decoded = raw == null || raw.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(raw) as Map<String, dynamic>);
    final currentCount = (decoded[hazardId] as num?)?.toInt() ?? 0;
    decoded[hazardId] = currentCount + 1;
    await prefs.setString(_confirmationsKey, jsonEncode(decoded));

    final confirmed = prefs.getStringList(_confirmedKey) ?? [];
    if (!confirmed.contains(hazardId)) {
      confirmed.add(hazardId);
      await prefs.setStringList(_confirmedKey, confirmed);
    }
  }

  Future<bool> _confirmReportFlow(HazardType type) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownWarning = prefs.getBool(_reportWarningShownKey) ?? false;
    if (hasShownWarning) {
      return true;
    }

    final typeLabel = type == HazardType.pothole ? 'bache' : 'tope';
    final message = StringBuffer()
      ..writeln('Por favor, reporta solo si lo ves en persona.')
      ..writeln('Los reportes falsos pueden ser filtrados y eliminados.');

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reportar $typeLabel'),
            content: Text(message.toString().trim()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reportar'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await prefs.setBool(_reportWarningShownKey, true);
    }

    return confirmed;
  }

  Future<bool> _checkReportLimits() async {
    // Reporting limits removed to allow unrestricted hazard reporting
    return true;
  }

  Future<void> _reportHazard(HazardType type) async {
    if (_currentPosition == null) {
      _showMessage('Ubicacion no disponible');
      return;
    }

    final okToReport = await _checkReportLimits();
    if (!okToReport) return;

    final confirmed = await _confirmReportFlow(type);
    if (!confirmed) return;

    await _getDeviceId();

    final description = type == HazardType.pothole
        ? 'Bache reportado desde la app'
        : 'Tope reportado desde la app';

    final hazard = Hazard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      reportedAt: DateTime.now(),
      reportedBy: 'app',
      description: description,
    );

    await _storageService.addHazard(hazard);
    await _loadHazards();
    await _storeReportTimestamp();

    _showMessage('${type == HazardType.pothole ? "Bache" : "Tope"} reportado!');
  }

  void _toggleVoiceListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      await _voiceService.startListening((text) {
        final hazardType = _voiceService.detectHazardType(text);
        if (hazardType != null) {
          _reportHazard(hazardType);
          _voiceService.stopListening();
          setState(() => _isListening = false);
        }
      });
      setState(() => _isListening = true);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showDriverPassengerChoice() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    final selection = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Antes de continuar'),
        content: const Text(
          'Selecciona tu rol. Si conduces, evita distraerte. Reporta solo cuando sea seguro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Pasajero'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conductor'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    final isDriver = selection ?? false;
    await prefs.setBool(_driverModeKey, isDriver);
    setState(() {
      _isDriver = isDriver;
    });

    if (isDriver) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seguridad al conducir'),
          content: const Text(
            'No uses la app mientras conduces si necesitas mirar la pantalla. Tu seguridad es primero.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openSettingsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    bool localVoiceEnabled = _voiceEnabled;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferencias'),
        content: StatefulBuilder(
          builder: (context, setLocalState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Reportes por voz')),
              Switch(
                value: localVoiceEnabled,
                onChanged: (value) {
                  setLocalState(() {
                    localVoiceEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await prefs.setBool(_voiceEnabledKey, localVoiceEnabled);
              if (mounted) {
                setState(() {
                  _voiceEnabled = localVoiceEnabled;
                  if (!_voiceEnabled && _isListening) {
                    _voiceService.stopListening();
                    _isListening = false;
                  }
                });
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _retryLocation() async {
    await _initializeServices();
  }

  Widget _buildLocationStatus() {
    if (_isLocating) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _locationError ?? 'Ubicacion no disponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _retryLocation,
                  child: const Text('Reintentar'),
                ),
                OutlinedButton(
                  onPressed: _openLocationSettings,
                  child: const Text('Ajustes de ubicacion'),
                ),
                OutlinedButton(
                  onPressed: _openAppSettings,
                  child: const Text('Ajustes de la app'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _notificationTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Baches y Topes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            fontSize: 20,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            tooltip: 'Preferencias',
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
        body: _currentPosition == null
          ? _buildLocationStatus()
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    initialZoom: 18,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && _followUser) {
                        setState(() {
                          _followUser = false;
                        });
                      }
                    },
                    onMapReady: () {
                      setState(() {
                        _mapReady = true;
                      });
                      if (_currentPosition != null) {
                        _updateCameraPosition(_currentPosition!);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.baches_y_topes',
                    ),
                    MarkerLayer(markers: _buildMapMarkers()),
                  ],
                ),
                Positioned(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  child: QuickReportWidget(onReport: _reportHazard),
                ),
                Positioned(
                  bottom: 300,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter',
                    onPressed: _centerOnUser,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _voiceEnabled
          ? VoiceListeningWidget(
              isListening: _isListening,
              onToggle: _toggleVoiceListening,
            )
          : null,
    );
  }
}
