# BachesYTopes App Architecture

## Overview
This document describes the architecture and component interactions of the BachesYTopes mobile application.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           User Interface                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     MapScreen (Main)                        │ │
│  │  - Google Maps Display                                      │ │
│  │  - Real-time Location Tracking                              │ │
│  │  - Hazard Markers                                           │ │
│  └────────────────────────────────────────────────────────────┘ │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │  QuickReportWidget    │  │  VoiceListeningWidget            │ │
│  │  - Pothole Button     │  │  - Microphone Toggle             │ │
│  │  - Speed Bump Button  │  │  - Listening Indicator           │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                        Business Logic                            │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ LocationService  │  │ NotificationSvc  │  │ VoiceRecogSvc │ │
│  │ - GPS Tracking   │  │ - TTS Alerts     │  │ - Speech2Text │ │
│  │ - Position Stream│  │ - Proximity Check│  │ - Keyword Det.│ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │          HazardStorageService                             │   │
│  │          - CRUD Operations                                │   │
│  │          - Proximity Queries                              │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────────┐  ┌──────────────────────────────────────┐ │
│  │   Hazard Model   │  │    SharedPreferences (Local)          │ │
│  │   - id           │  │    - JSON Serialization               │ │
│  │   - type         │  │    - Persistent Storage               │ │
│  │   - location     │  └──────────────────────────────────────┘ │
│  │   - timestamp    │                                            │
│  └──────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                     External Services                            │
│  ┌─────────────────┐  ┌────────────────┐  ┌──────────────────┐ │
│  │ Google Maps SDK │  │  Device GPS    │  │  Device Sensors  │ │
│  │ - Map Display   │  │  - Location    │  │  - Microphone    │ │
│  │ - Markers       │  │  - Speed       │  │  - Speaker       │ │
│  └─────────────────┘  └────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Hazard Reporting Flow
```
User Action (Button/Voice)
    ↓
MapScreen receives input
    ↓
Get current GPS position from LocationService
    ↓
Create Hazard object with coordinates
    ↓
Save to HazardStorageService
    ↓
Update map markers
    ↓
Show confirmation to user
```

### 2. Notification Flow
```
LocationService provides position updates (every 10m)
    ↓
MapScreen receives new position
    ↓
Query nearby hazards from HazardStorageService (500m radius)
    ↓
NotificationService calculates distances
    ↓
If hazard within 100m → Speak alert via TTS
    ↓
Mark hazard as notified (prevent duplicates)
```

### 3. Voice Recognition Flow
```
User taps microphone button
    ↓
VoiceRecognitionService starts listening
    ↓
User speaks "pothole" or "speed bump"
    ↓
Speech converted to text
    ↓
Keyword detection matches hazard type
    ↓
Auto-report at current location
```

## Key Design Decisions

### 1. Local-First Architecture
- All data stored locally using SharedPreferences
- No backend dependency for MVP
- Easy to extend with cloud sync in future

### 2. Service Separation
- Each major feature has dedicated service
- Clear separation of concerns
- Easy to test and maintain

### 3. Real-time Updates
- Position stream for continuous location tracking
- Timer-based notification checking (2s interval)
- Efficient marker updates

### 4. Platform Integration
- Native permissions handling (Android & iOS)
- Google Maps SDK integration
- Device sensors (GPS, microphone, speaker)

## Performance Considerations

1. **Location Updates**: Filtered to 10m distance to reduce battery drain
2. **Notification Checks**: 2-second intervals balance responsiveness and CPU usage
3. **Local Storage**: JSON-based with in-memory caching
4. **Distance Calculations**: Haversine formula for accurate geo-distance

## Security & Privacy

1. **Permissions**: Explicit user consent for location and microphone
2. **Data Privacy**: All data stored locally on device
3. **No User Tracking**: No analytics or tracking services
4. **Anonymous Reports**: No user identification in hazard data

## Extensibility Points

1. **Backend Integration**: Replace HazardStorageService with API calls
2. **User Accounts**: Add authentication service
3. **Photo Uploads**: Extend Hazard model with image URLs
4. **Social Features**: Add comments, votes, verification
5. **Navigation**: Integrate route planning to avoid hazards
