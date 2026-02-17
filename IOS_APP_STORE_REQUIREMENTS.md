# iOS App Store Submission Requirements for BachesYTopes

This document outlines the requirements and configuration needed to submit the BachesYTopes app to the Apple App Store.

## Prerequisites

### System Requirements
- macOS 12.0 or later
- Xcode 14.0 or later
- iOS deployment target: 12.0 or later (configured in Podfile)
- Apple Developer Account (paid)

## Required Configuration

### 1. App Icon
- ✅ Already enabled in `pubspec.yaml` (ios: true)
- Run the following to generate iOS icons:
  ```bash
  flutter pub get
  flutter pub run flutter_launcher_icons:main
  ```
- Verify icons are generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 2. App Display Name
- Currently set to "BachesYTopes" in `ios/Runner/Info.plist`
- Ensure it's user-friendly and matches your marketing materials

### 3. Permissions (Already Configured)
The following privacy permissions are configured in `ios/Runner/Info.plist`:
- ✅ Location: NSLocationWhenInUseUsageDescription
- ✅ Location Background: NSLocationAlwaysUsageDescription  
- ✅ Microphone: NSMicrophoneUsageDescription
- ✅ Speech Recognition: NSSpeechRecognitionUsageDescription

All permissions include user-friendly descriptions explaining why they're needed.

## Pre-Submission Checklist

### Privacy & Legal
- [ ] Create and host a Privacy Policy (required)
  - Must be accessible via a web URL
  - Must address location data collection, voice data, and user confirmations
  - Reference: https://www.termsfeed.com/privacy-policy/
  
- [ ] Update `Info.plist` with Privacy Policy URL (if needed for display)
  
- [ ] Understand App Privacy Nutrition Labels requirements:
  - Location data: YES (user's current position)
  - Microphone: YES (voice recognition for reporting)
  - Speech/Voice data: YES (voice commands)
  - Data linked to user: Depends on backend implementation
  - Tracking: Determine if you track user behavior

### App Features Review
- [ ] Test on actual iOS device(s) (iPad mini, iPhone 12-15)
- [ ] Verify voice recognition works without network (geolocator + text-to-speech)
- [ ] Test permission requests on fresh install
- [ ] Verify background location monitoring works correctly
- [ ] Test OpenStreetMap tiles load properly
- [ ] Verify all UI is responsive on various screen sizes

### Build Configuration
- [ ] Update version number in `pubspec.yaml`:
  ```yaml
  version: 1.0.0+1
  ```
  First number: App version, Second number: Build number

- [ ] Update bundle identifier in Xcode:
  - Open `ios/Runner.xcworkspace` in Xcode
  - Set Bundle Identifier to your company domain (e.g., `com.yourcompany.baches`)
  - Ensure it matches your App Store ID

### Code Review
- [ ] No hardcoded API keys or secrets
- [ ] Backend API uses HTTPS (currently: http://140.84.176.123:3000)
  - ⚠️ CRITICAL: Update to HTTPS before submission
  - Add to `Info.plist` if using non-standard ports:
    ```xml
    <key>NSAppTransportSecurity</key>
    <dict>
      <key>NSExceptionDomains</key>
      <dict>
        <key>your-domain.com</key>
        <dict>
          <key>NSIncludesSubdomains</key>
          <true/>
          <key>NSExceptionAllowsInsecureHTTPLoads</key>
          <true/>
          <key>NSExceptionMinimumTLSVersion</key>
          <string>TLSv1.2</string>
        </dict>
      </dict>
    </dict>
    ```
  
- [ ] No console warnings or errors on exit
- [ ] Performance tested (app load time, notification latency)

## Submission Steps

1. **Create App Details in App Store Connect:**
   - Visit https://appstoreconnect.apple.com
   - Create new app with appropriate Bundle ID
   - Fill in all required fields:
     - App name
     - Subtitle
     - Description
     - Screenshots (minimum 2 per device type)
     - Keywords
     - Support URL
     - Privacy Policy URL
     - Contact email

2. **Build for Release:**
   ```bash
   flutter build ios --release
   ```

3. **Archive and Upload:**
   - Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
   - Select "Generic iOS Device" or actual device
   - Product → Archive
   - Distribute App → App Store Connect → Upload

4. **Complete App Review:**
   - Fill in App Review information
   - Add privacy information and content ratings
   - Submit for review

## Important Notes

- **Location Services**: Your app monitors location in background. Clearly communicate this in your app description and privacy policy.
- **Voice Processing**: Explain how voice data is processed locally vs. sent to servers.
- **User Confirmations**: The confirmation flow helps prevent spam reports - highlight this as a feature.
- **Data Retention**: Define how long hazard reports are stored.

## Common Rejection Reasons

- ❌ Apps that collect location data without clear privacy policy
- ❌ Missing or incomplete privacy labels (App Privacy)
- ❌ Unencrypted backend communication (HTTP instead of HTTPS)
- ❌ Features that don't work as described
- ❌ Crashes or major bugs during testing
- ❌ Permission requests not clearly explained

## Support Resources

- Apple App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Flutter iOS Deployment: https://flutter.dev/docs/deployment/ios
- App Privacy Information: https://developer.apple.com/app-store/privacy/
- Privacy Policy Generator: https://www.termsfeed.com/privacy-policy/

## Testing Before Submission

```bash
# Generate iOS icons
flutter pub run flutter_launcher_icons:main

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on iOS simulator
flutter run -d "iPhone 14 Pro"

# Build release
flutter build ios --release

# Check for any warnings
```

---

**Last Updated:** February 2026
**Minimum iOS Version:** 12.0
**Flutter Version Requirement:** >= 3.0.0
