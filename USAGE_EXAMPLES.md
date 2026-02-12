# Usage Examples

This document provides step-by-step examples of how to use the BachesYTopes app in various scenarios.

## Scenario 1: First-Time User Setup

### Step 1: Install and Launch
1. Install the app from the app store or build from source
2. Launch BachesYTopes
3. Grant location permission when prompted
4. Grant microphone permission when prompted

### Step 2: Explore the Map
- The map automatically centers on your current location (blue dot)
- Zoom in/out with pinch gestures
- Pan around to see nearby areas
- Initially, no hazard markers will be visible

## Scenario 2: Reporting a Pothole (Button Method)

### Use Case
You're driving and spot a pothole. You want to report it quickly.

### Steps
1. **Stop safely** or have a passenger do this
2. Look at the bottom of the screen
3. Tap the **orange "Pothole" button**
4. Wait for the confirmation message: "Pothole reported!"
5. An orange marker appears on the map at your current location

### What Happens Behind the Scenes
- App captures your GPS coordinates
- Creates a Hazard record with type=pothole
- Saves to local storage
- Adds marker to map
- Other users (in future versions) will see this marker

## Scenario 3: Reporting a Speed Bump (Voice Method)

### Use Case
You're driving and encounter a speed bump. You want to report hands-free.

### Steps
1. Tap the **green microphone button** (bottom right)
2. Button turns red, indicating listening mode
3. Say clearly: **"Speed bump"**
4. Wait for confirmation: "Speed bump reported!"
5. A blue marker appears at your location
6. Microphone automatically turns off

### Tips for Best Results
- Speak clearly and at normal volume
- Minimize background noise
- Say either "pothole" OR "speed bump" (not both)
- Wait for visual feedback before continuing

## Scenario 4: Receiving a Proximity Alert

### Use Case
You're driving on a familiar route. Unknown to you, someone has reported a pothole ahead.

### What Happens
1. You're driving at 50 km/h (30 mph)
2. You come within 100 meters of the reported pothole
3. The app speaks: **"Caution! Pothole ahead in 85 meters"**
4. You slow down and safely navigate around the pothole
5. You continue driving
6. The same hazard won't alert you again unless you leave and re-approach

### Alert Variations by Speed

**High Speed (>18 km/h or 5 m/s):**
- "Caution! Pothole ahead in X meters"
- Urgent tone, early warning

**Low Speed (≤18 km/h):**
- "Pothole nearby, X meters ahead"
- Calmer tone, informational

## Scenario 5: Viewing Hazard Details

### Use Case
You see several markers on the map and want to know more about them.

### Steps
1. Tap on any colored marker
2. An info window appears showing:
   - Hazard type (Pothole or Speed Bump)
   - When it was reported (date and time)
3. Tap elsewhere to close the info window

### Marker Color Guide
- **🟠 Orange**: Pothole
- **🔵 Blue**: Speed Bump

## Scenario 6: Daily Commute Routine

### Morning Commute (7:30 AM)
1. Start the app before leaving
2. Place phone in holder
3. Enable voice mode (tap microphone)
4. Drive your normal route
5. If you see a hazard, say "pothole" or "speed bump"
6. App alerts you of previously reported hazards
7. Navigate safely around them

### Evening Return (6:00 PM)
1. App still running in background (if not closed)
2. Approaching hazards from opposite direction
3. Receive alerts for hazards you might have forgotten
4. Report any new hazards discovered

## Scenario 7: Community Reporting Party

### Use Case
A group of friends wants to map hazards in their neighborhood.

### Steps
1. Each person installs BachesYTopes
2. Split up and cover different streets
3. Walk or drive slowly through the area
4. Report every hazard encountered
5. Meet back and compare maps
6. Share screenshots to see coverage

### Tips
- Move at walking pace for best accuracy
- Double-check location before reporting
- Use button method for precise reporting
- Voice method works great while moving

## Scenario 8: Troubleshooting Common Issues

### Issue: "Location not available" message
**Solution:**
1. Open device Settings
2. Go to Location/Privacy
3. Find BachesYTopes
4. Enable "While Using App" permission
5. Restart the app

### Issue: Voice recognition not responding
**Solution:**
1. Check microphone permission in device settings
2. Ensure phone volume is up (for audio feedback)
3. Speak more clearly and directly
4. Try using button method instead
5. Check for background noise

### Issue: Map not loading
**Solution:**
1. Verify internet connection
2. Check Google Maps API key configuration
3. Restart the app
4. Clear app cache (in device settings)

### Issue: No hazards showing on map
**Solution:**
1. This is normal if no hazards have been reported nearby
2. Try zooming out to see wider area
3. Report a test hazard to verify functionality
4. Check that hazard markers aren't hidden by zoom level

## Advanced Usage Tips

### Battery Optimization
- Close the app when not in use
- Location updates are optimized (10m filter)
- Voice recognition only active when button is pressed
- Notifications check every 2 seconds (minimal drain)

### Accuracy Tips
- Report hazards when stationary for best accuracy
- Ensure clear sky view for GPS signal
- Avoid reporting in tunnels or parking garages
- Wait for GPS to stabilize (3-5 seconds)

### Safety First
- **Never** operate the app while actively driving
- Use voice commands only when safe
- Pull over to use button reporting
- Have a passenger operate the app if possible
- Don't let the app distract from driving

## Integration with Daily Life

### Morning Routine
```
Wake → Shower → Breakfast → Start App → Commute with Alerts
```

### School/Work Run
```
Start App → Voice Mode → Drop Kids → Report New Hazards → Park
```

### Evening Errands
```
Start App → Shopping Route → Report Hazards → Home Safe
```

### Weekend Road Trip
```
Long Drive → Voice Mode Active → Report Highway Hazards → Help Other Drivers
```

## Future Enhancements Preview

While not yet implemented, future versions may include:
- Photo attachment to reports
- Hazard verification by multiple users
- Route planning that avoids hazards
- Community leaderboards
- Municipal integration for repairs
- Real-time hazard resolution updates

---

**Remember:** The goal of BachesYTopes is to make roads safer for everyone. Report responsibly and drive safely!
