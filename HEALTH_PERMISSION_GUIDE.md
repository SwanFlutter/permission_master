# Health Permission Guide

## Overview

Health permission allows your app to access health and fitness data on iOS and Android devices. This guide explains how to implement and use health permissions across different platforms and OS versions.

## Platform Support

| Platform | Minimum Version | Status | Notes |
|----------|----------------|--------|-------|
| iOS | 13.0+ | ✅ Full Support | Requires HealthKit framework |
| iOS | 8.0-12.x | ⚠️ Limited | Basic HealthKit available but not recommended |
| iOS | < 8.0 | ❌ Not Supported | HealthKit not available |
| Android | 14+ (API 34+) | ✅ Full Support | Health Connect built-in |
| Android | 10-13 (API 29-33) | ⚠️ Requires App | Health Connect as separate app |
| Android | < 10 (API < 29) | ❌ Not Supported | Health Connect not available |
| macOS | All | ❌ Not Supported | HealthKit is iOS-only |
| Windows | All | ❌ Not Supported | - |
| Linux | All | ❌ Not Supported | - |
| Web | All | ❌ Not Supported | - |

## iOS Setup

### 1. Add HealthKit Capability

In Xcode, add HealthKit capability to your app:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your target (Runner)
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "HealthKit"

### 2. Update Info.plist

Add the following keys to `ios/Runner/Info.plist`:

```xml
<!-- Health Permission -->
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to read your health data to track your fitness progress</string>

<key>NSHealthUpdateUsageDescription</key>
<string>This app needs access to update your health data to record your activities</string>
```

### 3. Minimum iOS Version

Ensure your `ios/Podfile` has minimum iOS 13.0:

```ruby
platform :ios, '13.0'
```

Or better yet, use iOS 14.0+ for best compatibility:

```ruby
platform :ios, '14.0'
```

### 4. Health Data Types

The plugin requests access to the following health data types by default:

**Read Access:**
- Workouts
- Step Count
- Heart Rate
- Active Energy Burned
- Walking/Running Distance

**Write Access:**
- Workouts
- Step Count

You can customize these in the plugin source code if needed.

## Android Setup

### Android 14+ (API 34+)

Health Connect is built into Android 14+. No additional setup required.

### Android 10-13 (API 29-33)

Users need to install Health Connect from Google Play Store:
1. Open Google Play Store
2. Search for "Health Connect"
3. Install the app
4. Grant permissions through Health Connect app

### Permissions in AndroidManifest.xml

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Health Connect permissions for Android 14+ -->
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.WRITE_STEPS" />
<uses-permission android:name="android.permission.health.READ_HEART_RATE" />
<uses-permission android:name="android.permission.health.READ_DISTANCE" />
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />

<!-- For Android 13 and below -->
<queries>
    <package android:name="com.google.android.apps.healthdata" />
</queries>
```

## Usage

### Request Health Permission

```dart
import 'package:permission_master/permission_master.dart';

// Request health permission
final result = await PermissionMaster.requestHealthPermission();

if (result == 'granted') {
  print('Health permission granted');
} else if (result == 'denied') {
  print('Health permission denied');
} else if (result == 'NOT_SUPPORTED') {
  print('Health permission not supported on this device/OS version');
} else if (result == 'REQUIRES_HEALTH_CONNECT_APP') {
  print('Please install Health Connect app from Play Store');
} else if (result == 'OPEN_SETTINGS') {
  print('Health Connect settings opened');
}
```

### Check Health Permission Status

```dart
final status = await PermissionMaster.checkPermissionStatus('health');

switch (status) {
  case 'granted':
    print('Health permission is granted');
    break;
  case 'denied':
    print('Health permission is denied');
    break;
  case 'notDetermined':
    print('Health permission not determined yet');
    break;
  case 'unsupported':
    print('Health permission not supported');
    break;
}
```

## Return Values

### iOS

- `granted` - User granted health permission
- `denied` - User denied health permission
- `notDetermined` - User hasn't decided yet
- `NOT_SUPPORTED` - Device doesn't support HealthKit (iPad without Health app, iOS < 13)

### Android

- `OPEN_SETTINGS` - Health Connect settings opened (Android 14+)
- `REQUIRES_HEALTH_CONNECT_APP` - User needs to install Health Connect app (Android 10-13)
- `NOT_SUPPORTED` - Android version doesn't support Health Connect (< Android 10)

## Important Notes

### iOS

1. **Privacy by Design**: HealthKit doesn't allow apps to determine if permission was denied or not granted. The status might show as "notDetermined" even after denial.

2. **Background Access**: If you need background health data access, you must:
   - Enable Background Modes capability
   - Add "Health" background mode
   - Request background delivery in your code

3. **Health App Required**: The Health app must be installed and set up on the device.

4. **iPad Support**: Most iPads don't have the Health app, so HealthKit will return `NOT_SUPPORTED`.

### Android

1. **Health Connect App**: For Android 10-13, users must install Health Connect from Play Store first.

2. **Granular Permissions**: Health Connect uses granular permissions. Users can grant access to some data types and deny others.

3. **Settings Management**: The plugin opens Health Connect settings where users manage permissions. Your app cannot directly request permissions like other Android permissions.

4. **Data Sync**: Health Connect syncs data across apps. Changes in one app reflect in others.

## Troubleshooting

### iOS

**Problem**: Permission always returns "denied"
- **Solution**: Check if Health app is installed and set up
- **Solution**: Verify HealthKit capability is added in Xcode
- **Solution**: Check Info.plist has required usage descriptions

**Problem**: "NOT_SUPPORTED" on iPhone
- **Solution**: Ensure iOS version is 13.0 or higher
- **Solution**: Check if Health app is available (not available on some regions/devices)

### Android

**Problem**: "REQUIRES_HEALTH_CONNECT_APP" on Android 14+
- **Solution**: This shouldn't happen on Android 14+. Check device OS version.

**Problem**: Health Connect not opening
- **Solution**: Ensure Health Connect is installed (Android 10-13)
- **Solution**: Update Health Connect to latest version
- **Solution**: Check if device supports Health Connect

**Problem**: "NOT_SUPPORTED" on Android 10+
- **Solution**: Verify device manufacturer supports Health Connect
- **Solution**: Some custom Android ROMs may not support Health Connect

## Example App

See the example app for a complete implementation:

```dart
// example/lib/main.dart
ElevatedButton(
  onPressed: () async {
    final result = await PermissionMaster.requestHealthPermission();
    
    if (result == 'granted') {
      // Access health data
      print('You can now access health data');
    } else if (result == 'NOT_SUPPORTED') {
      // Show message to user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Not Supported'),
          content: Text(
            'Health permission is not supported on this device. '
            'Please ensure you have:\n'
            '- iOS 13.0+ or Android 10+\n'
            '- Health app (iOS) or Health Connect (Android) installed'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else if (result == 'REQUIRES_HEALTH_CONNECT_APP') {
      // Direct user to Play Store
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Install Health Connect'),
          content: Text(
            'Please install Health Connect from Google Play Store to use health features.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Open Play Store
                // You can use url_launcher package
                Navigator.pop(context);
              },
              child: Text('Install'),
            ),
          ],
        ),
      );
    }
  },
  child: Text('Request Health Permission'),
)
```

## Additional Resources

### iOS
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [HealthKit Authorization](https://developer.apple.com/documentation/healthkit/authorizing_access_to_health_data)

### Android
- [Health Connect Documentation](https://developer.android.com/health-and-fitness/guides/health-connect)
- [Health Connect Permissions](https://developer.android.com/health-and-fitness/guides/health-connect/develop/get-started)

## Version History

- **v0.1.0**: Initial health permission support
  - iOS 13.0+ support with HealthKit
  - Android 14+ support with built-in Health Connect
  - Android 10-13 support with Health Connect app
  - Proper version detection and error messages
