# BachesYTopes

A cross-platform mobile app for reporting potholes and speed bumps on the road, with real-time notifications for nearby hazards.

## Features

- **Interactive Map**: View your current location and all reported hazards on an interactive map
- **Hazard Reporting**: Quick-report buttons for easy pothole and speed bump reporting
- **Voice Recognition**: Hands-free reporting by saying "pothole" or "speed bump"
- **Proximity Notifications**: Spoken warnings when approaching reported hazards, adjusted based on your speed
- **Local Storage**: All hazard data stored locally on your device

## Installation

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Android Studio or Xcode for platform-specific builds
- Google Maps API key

### Setup

1. Clone the repository:
```bash
git clone https://github.com/HTVaquero/BachesYTopes.git
cd BachesYTopes
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Google Maps API:
   - Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
   - For Android: Update `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE"/>
     ```
   - For iOS: Add to `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
     ```

4. Run the app:
```bash
flutter run
```

## Usage

### Reporting a Hazard

1. **Using Buttons**: Tap the "Pothole" or "Speed Bump" button at the bottom of the screen
2. **Using Voice**: Tap the microphone button and say "pothole" or "speed bump"

### Receiving Notifications

- The app continuously monitors your location
- When approaching a reported hazard (within 100 meters), you'll hear a spoken warning
- Warning intensity adjusts based on your current speed

## Permissions

The app requires the following permissions:

- **Location**: To track your position and detect nearby hazards
- **Microphone**: For voice-activated reporting
- **Speech Recognition**: To process voice commands

## Architecture

```
lib/
├── main.dart                           # App entry point
├── models/
│   └── hazard.dart                     # Hazard data model
├── screens/
│   └── map_screen.dart                 # Main map screen with all features
├── services/
│   ├── hazard_storage_service.dart     # Local storage for hazards
│   ├── location_service.dart           # GPS location tracking
│   ├── notification_service.dart       # Proximity alerts
│   └── voice_recognition_service.dart  # Speech-to-text processing
└── widgets/
    ├── quick_report_widget.dart        # Quick report buttons
    └── voice_listening_widget.dart     # Voice control button
```

## Dependencies

- `google_maps_flutter`: Interactive map display
- `geolocator`: Location tracking
- `permission_handler`: Permission management
- `speech_to_text`: Voice recognition
- `flutter_tts`: Text-to-speech notifications
- `shared_preferences`: Local data storage

## License

MIT License
