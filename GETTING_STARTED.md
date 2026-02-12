# Getting Started with BachesYTopes

This guide will help you set up and run the BachesYTopes app on your development machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or later) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** (for Android development) or **Xcode** (for iOS development)
- **Git**
- A **Google Maps API Key** - [Get API Key](https://developers.google.com/maps/documentation/android-sdk/get-api-key)

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/HTVaquero/BachesYTopes.git
cd BachesYTopes
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps API Key

#### For Android:

1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...your-actual-key-here"/>
```

#### For iOS:

1. Open `ios/Runner/AppDelegate.swift`
2. Replace `YOUR_API_KEY_HERE` with your actual Google Maps API key:

```swift
GMSServices.provideAPIKey("AIzaSy...your-actual-key-here")
```

### 4. Check Your Flutter Installation

```bash
flutter doctor
```

Ensure all required components are installed. Fix any issues reported by `flutter doctor`.

### 5. Run the App

#### On an Android Device/Emulator:

```bash
flutter run
```

#### On an iOS Device/Simulator (macOS only):

```bash
flutter run -d ios
```

## Features Overview

### 1. Location Tracking
- The app automatically tracks your location when you open it
- Grant location permissions when prompted

### 2. Viewing Hazards
- Orange markers indicate potholes
- Blue markers indicate speed bumps
- Tap on markers to see details

### 3. Reporting Hazards

#### Using Quick Report Buttons:
1. Locate the buttons at the bottom of the screen
2. Tap "Pothole" or "Speed Bump"
3. The hazard is immediately reported at your current location

#### Using Voice Commands:
1. Tap the microphone button (bottom right)
2. Say "pothole" or "speed bump"
3. The app will automatically report the hazard

### 4. Receiving Notifications
- As you move, the app monitors nearby hazards
- When within 100 meters of a reported hazard, you'll hear a spoken alert
- Alert intensity varies based on your speed

## Troubleshooting

### Location Not Working
- Ensure location permissions are granted in device settings
- Check that location services are enabled on your device

### Voice Recognition Not Working
- Grant microphone permission when prompted
- Ensure speech recognition is available for your language (defaults to English)
- Check device volume is not muted

### Map Not Displaying
- Verify your Google Maps API key is correctly configured
- Ensure you have an active internet connection
- Check that the Maps SDK is enabled in Google Cloud Console

### Build Errors

#### Android:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### iOS:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
```

## Project Structure

```
BachesYTopes/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── models/
│   │   └── hazard.dart                 # Data model for hazards
│   ├── screens/
│   │   └── map_screen.dart             # Main map interface
│   ├── services/
│   │   ├── hazard_storage_service.dart # Data persistence
│   │   ├── location_service.dart       # GPS tracking
│   │   ├── notification_service.dart   # Audio alerts
│   │   └── voice_recognition_service.dart # Speech recognition
│   └── widgets/
│       ├── quick_report_widget.dart    # Report buttons
│       └── voice_listening_widget.dart # Voice control button
├── test/
│   └── hazard_test.dart                # Unit tests
├── android/                            # Android-specific files
├── ios/                                # iOS-specific files
└── pubspec.yaml                        # Dependencies configuration
```

## Performance Tips

- The app stores hazards locally using SharedPreferences
- Location updates occur every 10 meters of movement
- Notifications are checked every 2 seconds
- Voice recognition remains active while the microphone button is pressed

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/HTVaquero/BachesYTopes/issues)
- Check the [Flutter documentation](https://docs.flutter.dev)

## Next Steps

- Consider implementing backend storage for shared hazards
- Add user accounts and social features
- Implement hazard verification system
- Add photos to hazard reports
- Create hazard removal/resolution workflow
