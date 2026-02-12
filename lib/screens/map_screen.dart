import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hazard.dart';
import '../services/hazard_storage_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/voice_recognition_service.dart';
import '../widgets/quick_report_widget.dart';
import '../widgets/voice_listening_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final HazardStorageService _storageService = HazardStorageService();
  final NotificationService _notificationService = NotificationService();
  final VoiceRecognitionService _voiceService = VoiceRecognitionService();

  Position? _currentPosition;
  List<Hazard> _hazards = [];
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionSubscription;
  Timer? _notificationTimer;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _locationService.requestPermission();
    await _voiceService.requestPermission();
    await _voiceService.initialize();
    
    _loadHazards();
    _startLocationTracking();
    _startNotificationChecking();
  }

  Future<void> _loadHazards() async {
    final hazards = await _storageService.getAllHazards();
    setState(() {
      _hazards = hazards;
      _updateMarkers();
    });
  }

  void _startLocationTracking() {
    _positionSubscription = _locationService.getPositionStream().listen((position) {
      setState(() {
        _currentPosition = position;
        _updateCameraPosition(position);
      });
    });
  }

  void _startNotificationChecking() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPosition != null) {
        _checkNearbyHazards();
      }
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
    );
  }

  void _updateCameraPosition(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  void _updateMarkers() {
    _markers = _hazards.map((hazard) {
      return Marker(
        markerId: MarkerId(hazard.id),
        position: LatLng(hazard.latitude, hazard.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          hazard.type == HazardType.pothole
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: hazard.type == HazardType.pothole ? 'Pothole' : 'Speed Bump',
          snippet: 'Reported: ${hazard.reportedAt.toString().substring(0, 16)}',
        ),
      );
    }).toSet();
  }

  Future<void> _reportHazard(HazardType type) async {
    if (_currentPosition == null) {
      _showMessage('Location not available');
      return;
    }

    final hazard = Hazard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      reportedAt: DateTime.now(),
      reportedBy: 'user',
    );

    await _storageService.addHazard(hazard);
    await _loadHazards();

    _showMessage('${type == HazardType.pothole ? "Pothole" : "Speed bump"} reported!');
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

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _notificationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BachesYTopes'),
        backgroundColor: Colors.green,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  child: QuickReportWidget(onReport: _reportHazard),
                ),
              ],
            ),
      floatingActionButton: VoiceListeningWidget(
        isListening: _isListening,
        onToggle: _toggleVoiceListening,
      ),
    );
  }
}
