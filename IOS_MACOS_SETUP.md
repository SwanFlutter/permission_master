# iOS and macOS Setup Guide

## iOS Setup

### Minimum Requirements
- iOS 14.0 or higher
- Swift Package Manager enabled

### 1. Enable Swift Package Manager
```bash
flutter config --enable-swift-package-manager
```

### 2. Update Podfile
Update your `ios/Podfile` to use iOS 14.0 or higher:
```ruby
platform :ios, '14.0'
```

### 3. Add Permission Descriptions to Info.plist
Add the following keys to your `ios/Runner/Info.plist`:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to take photos and videos</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select images</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs access to save photos to your library</string>

<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to provide location-based services</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location for the best user experience</string>

<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone to record audio</string>

<!-- Contacts Permission -->
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts</string>

<!-- Bluetooth Permission -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs access to Bluetooth to connect to devices</string>

<!-- Calendar Permission -->
<key>NSCalendarsUsageDescription</key>
<string>This app needs access to your calendar</string>

<!-- Motion/Sensors Permission -->
<key>NSMotionUsageDescription</key>
<string>This app needs access to motion sensors to track your activity</string>

<!-- Speech Recognition Permission -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to transcribe your voice</string>

<!-- Apple Music Permission -->
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library to play and manage your music</string>

<!-- Health Permission -->
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to read your health data</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs access to update your health data</string>

<!-- Reminders Permission -->
<key>NSRemindersUsageDescription</key>
<string>This app needs access to your reminders to manage tasks</string>
```

### 4. Clean and Rebuild
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

## macOS Setup

### Minimum Requirements
- macOS 10.15 or higher
- Swift Package Manager enabled

### 1. Update Platform Version
The plugin requires macOS 10.15 or higher. Update your `macos/Runner.xcodeproj` settings accordingly.

### 2. Add Permission Descriptions to Info.plist
Add the same permission descriptions to your `macos/Runner/Info.plist` as needed for your app.

### 3. Known Issues and Workarounds

#### Location Permission
- **Issue**: Method is called but no feedback
- **Workaround**: Ensure location services are enabled in System Preferences

#### Bluetooth Permission
- **Issue**: Method is called but no feedback
- **Workaround**: Check System Preferences > Security & Privacy > Bluetooth

#### Calendar Permission
- **Issue**: Shows Settings dialog but not the app
- **Workaround**: User must manually grant permission in System Preferences

#### Activity Recognition Permission
- **Status**: NOT_SUPPORTED on macOS
- **Reason**: Activity recognition is iOS-only

#### Music Library Permission
- **Status**: NOT_SUPPORTED on macOS
- **Reason**: Music library access requires different APIs on macOS

#### Health Permission
- **Status**: Missing plugin implementation
- **Reason**: HealthKit is iOS-only, macOS doesn't support HealthKit

## iOS Known Issues

### Activity Recognition Permission
- **Issue**: Missing plugin message in app
- **Fix**: Added `requestActivityRecognitionPermission` method handler

### Health Permission
- **Issue**: Denied (data settings missing)
- **Note**: Health permission requires specific health data types to be requested. You need to specify which health data types you want to read/write before requesting permission.

Example:
```dart
// You may need to implement a more specific health permission request
// that specifies the health data types you want to access
```

## Testing Permissions

### iOS Testing
1. Reset permissions: Settings > General > Reset > Reset Location & Privacy
2. Uninstall and reinstall the app
3. Test each permission individually

### macOS Testing
1. Reset permissions: System Preferences > Security & Privacy > Privacy
2. Remove the app from the list for each permission type
3. Test each permission individually

## Supported Permissions

### iOS
- ✅ Camera
- ✅ Photos
- ✅ Location
- ✅ Contacts
- ✅ Bluetooth
- ✅ Microphone
- ✅ Notifications
- ✅ Calendar
- ✅ Motion/Activity Recognition
- ✅ Speech Recognition
- ✅ Reminders
- ✅ Music Library
- ⚠️ Health (requires additional configuration)

### macOS
- ✅ Camera
- ✅ Photos
- ⚠️ Location (limited feedback)
- ✅ Contacts
- ⚠️ Bluetooth (limited feedback)
- ✅ Microphone
- ✅ Notifications
- ⚠️ Calendar (shows settings dialog)
- ❌ Activity Recognition (NOT_SUPPORTED)
- ✅ Speech Recognition
- ✅ Reminders
- ❌ Music Library (NOT_SUPPORTED)
- ❌ Health (NOT_SUPPORTED)

## Troubleshooting

### "Plugin permission_master is only Swift Package Manager compatible"
Run: `flutter config --enable-swift-package-manager`

### Permission always returns denied
1. Check Info.plist has the correct usage description
2. Reset app permissions
3. Check System Preferences/Settings

### Build errors on iOS
1. Clean build: `flutter clean`
2. Remove Pods: `cd ios && rm -rf Pods Podfile.lock && pod install`
3. Rebuild: `flutter run`

### Build errors on macOS
1. Ensure minimum platform is 10.15
2. Clean build: `flutter clean`
3. Rebuild: `flutter run`
