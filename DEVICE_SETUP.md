# Device Setup & Compilation Guide for BachesYTopes

## Current Setup Status

| Platform     | Status | Build | Run |
|-------------|--------|-------|-----|
| Chrome      | ✅ Ready | ✅ Works | ✅ Run: `flutter run -d chrome` |
| Edge        | ✅ Ready | ✅ Works | ✅ Run: `flutter run -d edge` |
| Windows Desktop | ❌ Missing Desktop support | ❌ Blocked on VS C++ | - |
| Android     | ⚠️ Partial | 🟡 Needs SDK tools | Needs emulator/device |
| iOS         | ⚠️ Partial | 🟡 macOS only | Needs Xcode setup |

## Available Devices

```
flutter devices
```

**Currently Available:**
- Windows (web host)
- Chrome (web browser)
- Edge (web browser)

## Setting Up Android Development

### Step 1: Install Android SDK Command-line Tools

**Current Issue:** `cmdline-tools` component is missing

**Option A: Using Android Studio (Recommended)**
```bash
1. Open Android Studio
2. File → Settings (or Preferences on macOS)
3. Navigate to Languages & Frameworks → Android SDK
4. Click "SDK Tools" tab
5. Check "Android SDK Command-line Tools (latest)"
6. Click "Apply" → OK
7. Restart Android Studio
```

**Option B: Manual Installation**
```bash
# Set ANDROID_HOME if not already set
$env:ANDROID_HOME = "C:\Android"

# Download and extract cmdline-tools from:
# https://developer.android.com/studio/command-line/sdkmanager

# Add to PATH
$env:PATH += ";C:\Android\cmdline-tools\latest\bin"
```

### Step 2: Create Virtual Device (Emulator)

**Via Android Studio:**
```
1. Tools → Device Manager
2. Click "Create Device"
3. Select "Pixel 6" or similar (modern device)
4. Select Android version 12+ (API level 31+)
5. Click "Next" → "Finish"
6. Click the "Play" button to launch
```

**Via Command Line:**
```bash
# List available system images
flutter emulators

# Create a new emulator
flutter emulators create --name pixel_6

# Launch emulator
flutter emulators launch pixel_6

# Then run
flutter run
```

**Verifying Setup:**
```bash
flutter devices
# Should show: android-x86_64 (mobile) • emulator-5554 • ...
```

### Step 3: Compile for Android

**Development Build:**
```bash
flutter run
```

**Release APK:**
```bash
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

**Play Store Bundle:**
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

## Setting Up Physical Android Device

### Prerequisites
- USB cable
- Device with Android 8.0+ (API level 26+)

### Step 1: Enable Developer Mode

On your Android device:
```
1. Settings → About Phone
2. Tap "Build Number" 7 times
3. Back to Settings → Developer Options (newly visible)
4. Enable "USB Debugging"
5. Enable "Install via USB" (if available)
```

### Step 2: Connect Device

```bash
# Connect via USB
# Grant permission on device when prompted

# Verify connection
flutter devices
# Should list: "DEVICE_ID (mobile) • device • android-arm64 • ..."

# Run app
flutter run
```

### Step 3: Install Debug APK

```bash
# Build and install
flutter run

# Or manually
flutter build apk
adb install build/app/outputs/apk/debug/app-debug.apk
```

## Setting Up iOS Development (macOS Only)

### Prerequisites
- macOS 12.0+
- Xcode 13.0+
- Apple Developer account (for physical device)

### Step 1: Install Xcode Dependencies

```bash
# Install/update xcode tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcode-select --reset

# Accept Xcode license
sudo xcode-select --install
sudo spctl --master-disable # May be needed for some builds
```

### Step 2: Create iOS Simulator

```bash
# List available simulators
xcrun simctl list devices available

# Create new simulator
xcrun simctl create "iPhone 15" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-15 \
  com.apple.CoreSimulator.SimRuntime.iOS-17-0

# Boot simulator
xcrun simctl boot "iPhone 15"

# Or use Xcode: Window → Devices and Simulators
```

### Step 3: Run on Simulator

```bash
# Open simulator first
open -a Simulator

# Run app
flutter run -d ios

# Or specific simulator
flutter run -d iPhone\ 15
```

### Step 4: Setup Physical Device (Requires Apple Developer Account)

```bash
# Trust the device in System Preferences

# Run on device
flutter run -d <device-name>

# For first-time setup, may need to use Xcode
# cd ios && xcode-select . && cd ..
```

## Setting Up Windows Desktop (Not Available Yet)

**Current Status:** ❌ Requires Visual Studio C++ Desktop Development

To enable Windows desktop support:
```bash
# Install Visual Studio Community
# https://visualstudio.microsoft.com/downloads/

# During installation, select:
# "Desktop development with C++" workload
# Include all default components

# Then run
flutter doctor

# Should show: Visual Studio - develop Windows apps [✓]
```

## Web Builds (Already Configured ✅)

### Development Mode

**Chrome:**
```bash
flutter run -d chrome
```

**Edge:**
```bash
flutter run -d edge
```

**Live Reload:**
- Edit code
- Press 'R' in terminal to reload
- Press 'Shift+R' for full restart

### Release Build

```bash
# Build for production
flutter build web --release

# Output: build/web/
# Serving: Can use any static web server
# Example: python -m http.server 8000
```

### Deployment

The web build creates a static site you can deploy to:
- Firebase Hosting
- Netlify
- GitHub Pages
- Any static hosting service

## Important Configuration Issues

### Google Maps API Key ⚠️ CRITICAL

Currently set to placeholder: `YOUR_API_KEY_HERE`

**For testing without Maps:**
- App will still run but map display will fail
- All other features work (voice, location, storage)

**To configure properly:**

1. **Get API Key from Google Cloud**
   - Go to https://console.cloud.google.com/
   - Create new project
   - Enable Maps SDK for Android
   - Create API Key
   - Restrict to Android with app signature

2. **Set API Key in code:**

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSy[YOUR_API_KEY]"/>
   ```

   **iOS** (`ios/Runner/AppDelegate.swift`):
   ```swift
   GMSServices.provideAPIKey("AIzaSy[YOUR_API_KEY]")
   ```

### Permissions Configuration ✅ Already Configured

The app requires these permissions:
- **Location** (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION) - ✅ Configured
- **Microphone** (RECORD_AUDIO) - ✅ Configured  
- **Internet** - ✅ Configured

These are automatically requested at runtime on modern Android/iOS devices.

## Testing Checklist

### Basic Functionality
- [ ] App launches without errors
- [ ] Map displays (after API key configured)
- [ ] Current location shows
- [ ] Can report hazards (buttons work)
- [ ] Voice recognition initializes

### Android Testing
- [ ] Runs on emulator
- [ ] Runs on physical device
- [ ] Location permission request appears
- [ ] Microphone permission request appears
- [ ] All features accessible

### iOS Testing (macOS only)
- [ ] Runs on simulator
- [ ] Runs on physical device
- [ ] Permission dialogs appear properly
- [ ] All features accessible

### Web Testing
- [ ] Loads in Chrome
- [ ] Loads in Edge
- [ ] UI is responsive
- [x] All features accessible (except GPS/mic without special permissions)

## Build Verification

```bash
# Check all builds are clean
flutter clean
flutter pub get

# Run all tests
flutter test

# Analyze code
flutter analyze

# Build for all available platforms
flutter build apk
flutter build web --release
flutter build ipa
```

## Troubleshooting

### "No connected devices"
```bash
flutter devices
flutter emulators --launch <name>
# Or
flutter run -d chrome
```

### "SDK is not specified for module"
```bash
flutter clean
flutter pub get
flutter run
```

### "Google Maps not displaying"
- Verify API key is set
- Check Maps SDK is enabled in Google Cloud
- Ensure API key isn't restricted by wrong package name

### "Permission denied" errors
- Physical device: Manually grant in Settings → Apps → Permissions
- Emulator: Grant in Settings when prompted

### "gradle failed"
```bash
flutter clean
rm -rf .gradle
flutter pub get
flutter run
```

## Recommended Next Steps

1. **[CRITICAL]** Configure Google Maps API key
2. **[IMPORTANT]** Install Android cmdline-tools
3. Test web build (already working)
4. Set up Android emulator
5. Test on Android virtual device
6. Test on physical Android device (if available)
7. Set up iOS simulator (macOS only)
8. Configure for release builds
9. Prepare for app store submission

## Resources

- [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- [Google Maps Setup](https://developers.google.com/maps/documentation/android-sdk/get-api-key)  
- [Android Development Setup](https://flutter.dev/docs/get-started/install/windows#android-setup)
- [iOS Development Setup](https://flutter.dev/docs/get-started/install/macos#ios-setup)
- [Web Deployment](https://flutter.dev/docs/deployment/web)
