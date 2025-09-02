# Permission Master Flutter Plugin

## Overview

Permission Master is a comprehensive Flutter plugin designed to simplify permission management across iOS and Android platforms. It provides an intuitive and easy-to-use interface for requesting and checking various system permissions while ensuring a smooth user experience.

## Key Features

- Simplified permission request methods
- Granular permission control
- Context-aware permission dialogs
- Platform-agnostic API
- Built-in storage for permission states
- Manual permission configuration required (no default permissions included)

iOS platform requirement (iOS 12.0 and above)
Supported platform Android (5.0 to 15)

<img src="https://github.com/user-attachments/assets/56d4dc2c-bc42-4124-abe0-592b092c7ae1" width="350"> <img src="https://github.com/user-attachments/assets/77eda07d-caf4-40c4-857b-6dca12e27c48" width="350">

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  permission_master: ^0.0.10
```

Or install directly from GitHub:

```yaml
dependencies:
  permission_master:
    git:
      url: https://github.com/SwanFlutter/permission_master.git
```

## Setup and Initialization

### 1. Import the Package

```dart
import 'package:permission_master/permission_master.dart';
```

### 2. Set BuildContext (Important for Dialogs)

```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set context for dialog support
    PermissionMaster.setContext(context);
  }
}
```

## Comprehensive Permission Methods

### 1. Camera Permission

#### Android Example:
```dart
Future<void> requestCameraAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  // Check current status first
  final currentStatus = await permissionMaster.checkPermissionStatus(PermissionType.camera.value);
  
  if (currentStatus == PermissionStatus.granted) {
    // Camera already granted, proceed with camera functionality
    print('Camera permission already granted');
    return;
  }
  
  // Request camera permission
  final status = await permissionMaster.requestCameraPermission();
  
  switch (status) {
    case PermissionStatus.granted:
      // Camera access allowed - start camera functionality
      print('Camera permission granted - can now use camera');
      break;
    case PermissionStatus.denied:
      // User denied permission - show explanation
      print('Camera permission denied by user');
      break;
    case PermissionStatus.openSettings:
      // Permanent denial - redirect to settings
      print('Camera permission permanently denied - opening settings');
      await permissionMaster.openAppSettings();
      break;
    case PermissionStatus.unsupported:
      print('Camera permission not supported on this device');
      break;
    case PermissionStatus.error:
      print('Error requesting camera permission');
      break;
  }
}
```

#### iOS Example:
```dart
Future<void> requestCameraAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  // iOS specific camera permission handling
  final status = await permissionMaster.requestCameraPermission();
  
  if (status == PermissionStatus.granted) {
    // Camera access granted - can use AVCaptureSession
    print('Camera permission granted - can access AVCaptureSession');
  } else if (status == PermissionStatus.denied) {
    // Show user-friendly message for iOS
    print('Camera access denied. Please enable in Settings > Privacy & Security > Camera');
  } else if (status == PermissionStatus.openSettings) {
    // Direct user to iOS Settings
    await permissionMaster.openAppSettings();
  }
}
```

### 2. Location Permission

#### Android Example:
```dart
Future<void> requestLocationAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  // Request location permission
  final status = await permissionMaster.requestLocationPermission();
  
  switch (status) {
    case PermissionStatus.granted:
      // Location access granted - can use GPS, Network location
      print('Location permission granted - can access GPS and network location');
      // Start location services
      break;
    case PermissionStatus.denied:
      // User denied location permission
      print('Location permission denied');
      break;
    case PermissionStatus.openSettings:
      // Permanent denial - open Android settings
      print('Location permission permanently denied - opening Android settings');
      await permissionMaster.openAppSettings();
      break;
    default:
      print('Error requesting location permission');
  }
}
```

#### iOS Example:
```dart
Future<void> requestLocationAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  // iOS location permission handling
  final status = await permissionMaster.requestLocationPermission();
  
  if (status == PermissionStatus.granted) {
    // Location access granted - can use CLLocationManager
    print('Location permission granted - can use CLLocationManager');
  } else if (status == PermissionStatus.denied) {
    // iOS specific location denial message
    print('Location access denied. Enable in Settings > Privacy & Security > Location Services');
  } else if (status == PermissionStatus.openSettings) {
    // Direct to iOS Settings app
    await permissionMaster.openAppSettings();
  }
}
```

### 3. Storage Permission

#### Android Example:
```dart
Future<void> requestStorageAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  // Android storage permission (handles API levels automatically)
  final status = await permissionMaster.requestStoragePermission();
  
  if (status == PermissionStatus.granted) {
    // Storage access granted - can read/write external storage
    print('Storage permission granted - can access external storage');
    // For Android 11+ (API 30+), consider using scoped storage
  } else if (status == PermissionStatus.denied) {
    print('Storage permission denied');
  } else if (status == PermissionStatus.openSettings) {
    // Open Android storage settings
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestStorageAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  // iOS storage/photo library access
  final status = await permissionMaster.requestStoragePermission();
  
  if (status == PermissionStatus.granted) {
    // Photo library access granted - can use PHPhotoLibrary
    print('Photo library access granted - can use PHPhotoLibrary');
  } else if (status == PermissionStatus.denied) {
    print('Photo library access denied. Enable in Settings > Privacy & Security > Photos');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 4. Microphone Permission

#### Android Example:
```dart
Future<void> requestMicrophoneAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestMicrophonePermission();
  
  if (status == PermissionStatus.granted) {
    // Microphone access granted - can use MediaRecorder, AudioRecord
    print('Microphone permission granted - can record audio');
  } else if (status == PermissionStatus.denied) {
    print('Microphone permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestMicrophoneAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestMicrophonePermission();
  
  if (status == PermissionStatus.granted) {
    // Microphone access granted - can use AVAudioSession
    print('Microphone permission granted - can use AVAudioSession');
  } else if (status == PermissionStatus.denied) {
    print('Microphone access denied. Enable in Settings > Privacy & Security > Microphone');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 5. Bluetooth Permission

#### Android Example:
```dart
Future<void> requestBluetoothAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestBluetoothPermission();
  
  if (status == PermissionStatus.granted) {
    // Bluetooth access granted - can use BluetoothAdapter
    print('Bluetooth permission granted - can use BluetoothAdapter');
  } else if (status == PermissionStatus.denied) {
    print('Bluetooth permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestBluetoothAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestBluetoothPermission();
  
  if (status == PermissionStatus.granted) {
    // Bluetooth access granted - can use CBCentralManager
    print('Bluetooth permission granted - can use CBCentralManager');
  } else if (status == PermissionStatus.denied) {
    print('Bluetooth access denied. Enable in Settings > Privacy & Security > Bluetooth');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 6. Contacts Permission

#### Android Example:
```dart
Future<void> requestContactsAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestContactsPermission();
  
  if (status == PermissionStatus.granted) {
    // Contacts access granted - can use ContactsContract
    print('Contacts permission granted - can access ContactsContract');
  } else if (status == PermissionStatus.denied) {
    print('Contacts permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestContactsAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestContactsPermission();
  
  if (status == PermissionStatus.granted) {
    // Contacts access granted - can use CNContactStore
    print('Contacts permission granted - can use CNContactStore');
  } else if (status == PermissionStatus.denied) {
    print('Contacts access denied. Enable in Settings > Privacy & Security > Contacts');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 7. Notifications Permission

#### Android Example:
```dart
Future<void> requestNotificationsAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestNotificationPermission();
  
  if (status == PermissionStatus.granted) {
    // Notification permission granted - can send notifications
    print('Notification permission granted - can send push notifications');
  } else if (status == PermissionStatus.denied) {
    print('Notification permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestNotificationsAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestNotificationPermission();
  
  if (status == PermissionStatus.granted) {
    // Notification permission granted - can use UNUserNotificationCenter
    print('Notification permission granted - can use UNUserNotificationCenter');
  } else if (status == PermissionStatus.denied) {
    print('Notification access denied. Enable in Settings > Notifications');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 8. SMS Permission (Android Only)

#### Android Example:
```dart
Future<void> requestSmsAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestSmsPermission();
  
  if (status == PermissionStatus.granted) {
    // SMS permission granted - can send SMS
    print('SMS permission granted - can send SMS messages');
  } else if (status == PermissionStatus.denied) {
    print('SMS permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.unsupported) {
    print('SMS permission not supported on iOS');
  }
}
```

### 9. Calendar Permission

#### Android Example:
```dart
Future<void> requestCalendarAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestCalendarPermission();
  
  if (status == PermissionStatus.granted) {
    // Calendar access granted - can use CalendarContract
    print('Calendar permission granted - can access CalendarContract');
  } else if (status == PermissionStatus.denied) {
    print('Calendar permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestCalendarAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestCalendarPermission();
  
  if (status == PermissionStatus.granted) {
    // Calendar access granted - can use EKEventStore
    print('Calendar permission granted - can use EKEventStore');
  } else if (status == PermissionStatus.denied) {
    print('Calendar access denied. Enable in Settings > Privacy & Security > Calendars');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 10. Phone Permission (Android Only)

#### Android Example:
```dart
Future<void> requestPhoneAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestPhonePermission();
  
  if (status == PermissionStatus.granted) {
    // Phone permission granted - can access phone state
    print('Phone permission granted - can access TelephonyManager');
  } else if (status == PermissionStatus.denied) {
    print('Phone permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.unsupported) {
    print('Phone permission not supported on iOS');
  }
}
```

### 11. Activity Recognition Permission

#### Android Example:
```dart
Future<void> requestActivityRecognitionAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestActivityRecognitionPermission();
  
  if (status == PermissionStatus.granted) {
    // Activity recognition granted - can use ActivityRecognitionClient
    print('Activity recognition permission granted');
  } else if (status == PermissionStatus.denied) {
    print('Activity recognition permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestActivityRecognitionAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestActivityRecognitionPermission();
  
  if (status == PermissionStatus.granted) {
    // Motion activity granted - can use CMMotionActivityManager
    print('Motion activity permission granted - can use CMMotionActivityManager');
  } else if (status == PermissionStatus.denied) {
    print('Motion activity denied. Enable in Settings > Privacy & Security > Motion & Fitness');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 12. Nearby Devices Permission

#### Android Example:
```dart
Future<void> requestNearbyDevicesAccessAndroid() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestNearbyDevicesPermission();
  
  if (status == PermissionStatus.granted) {
    // Nearby devices permission granted
    print('Nearby devices permission granted');
  } else if (status == PermissionStatus.denied) {
    print('Nearby devices permission denied');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

#### iOS Example:
```dart
Future<void> requestNearbyDevicesAccessiOS() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestNearbyDevicesPermission();
  
  if (status == PermissionStatus.granted) {
    // Nearby interaction granted - can use NISession
    print('Nearby interaction permission granted - can use NISession');
  } else if (status == PermissionStatus.denied) {
    print('Nearby interaction denied. Enable in Settings > Privacy & Security');
  } else if (status == PermissionStatus.openSettings) {
    await permissionMaster.openAppSettings();
  }
}
```

### 13. Multiple Permission Checking

```dart
Future<void> checkMultiplePermissions() async {
  final permissionMaster = PermissionMaster();
  
  final statuses = await permissionMaster.checkMultiplePermissions([
    PermissionType.camera,
    PermissionType.fineLocation,
    PermissionType.microphone,
    PermissionType.contacts,
    PermissionType.notifications,
  ]);

  statuses.forEach((permission, status) {
    print('$permission status: $status');
    
    switch (status) {
      case PermissionStatus.granted:
        print('✅ $permission is granted');
        break;
      case PermissionStatus.denied:
        print('❌ $permission is denied');
        break;
      case PermissionStatus.openSettings:
        print('⚠️ $permission needs settings adjustment');
        break;
      case PermissionStatus.unsupported:
        print('🚫 $permission is not supported');
        break;
      case PermissionStatus.error:
        print('💥 Error with $permission');
        break;
    }
  });
}
```

### 14. Custom Permission Dialog

```dart
Future<void> requestPermissionWithCustomDialog() async {
  final permissionMaster = PermissionMaster();
  
  final status = await permissionMaster.requestPermissionWithDialog(
    permission: PermissionType.camera,
    title: 'Camera Access Required',
    message: 'This app needs camera access to take photos and scan QR codes. Please allow camera permission to continue.',
  );
  
  if (status == PermissionStatus.granted) {
    print('Camera permission granted with custom dialog');
  } else {
    print('Camera permission denied');
  }
}
```

### 15. Open App Settings

```dart
Future<void> openAppPermissionSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettings();
}

// Direct settings opening without dialog
Future<void> openSettingsDirectly() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettingsDirectly();
}
```

## Built-in Storage

Permission Master comes with a built-in storage system (`GetStorageBridge`) that allows you to persist permission states and other data across app sessions.

### Basic Storage Operations

```dart
// Import the storage bridge
import 'package:permission_master/src/get_storage_bridge.dart';

// Create a storage instance
final storage = GetStorageBridge();

// Write a value
await storage.write('myKey', 'myValue');

// Read a value with a default fallback
final value = await storage.read('myKey', 'defaultValue');

// Check if a key exists
final exists = await storage.contains('myKey');

// Remove a key
await storage.remove('myKey');

// Clear all stored data
await storage.clear();
```

### Storing Permission Data

```dart
Future<void> trackPermissionRequest(PermissionType permission, PermissionStatus status) async {
  final storage = GetStorageBridge();

  // Store the permission status
  await storage.write('permission_${permission.value}_status', status.toString());

  // Store the timestamp of the request
  await storage.write(
    'permission_${permission.value}_last_request_time',
    DateTime.now().millisecondsSinceEpoch,
  );

  // Increment the request count
  int requestCount = await storage.read(
    'permission_${permission.value}_request_count',
    0,
  );
  await storage.write(
    'permission_${permission.value}_request_count',
    requestCount + 1,
  );
}
```

## Supported Permissions

| Permission Type      | Android | iOS | Windows | macOS | Linux | Web |
|----------------------|:-------:|:---:|:-------:|:-----:|:-----:|:---:|
| Camera               |    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |
| Location             |    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |
| Storage/Photo Library|    ✅    |  ✅  |    ❌    |   ✅   |   ✅   |  ✅  |
| Microphone           |    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |
| Bluetooth            |    ✅    |  ✅  |    ❌    |   ❌   |   ✅   |  ❌  |
| Contacts             |    ✅    |  ✅  |    ❌    |   ✅   |   ❌   |  ❌  |
| Notifications        |    ✅    |  ✅  |    ❌    |   ❌   |   ❌   |  ✅  |
| SMS                  |    ✅    |  ❌  |    ❌    |   ❌   |   ❌   |  ❌  |
| Calendar             |    ✅    |  ✅  |    ❌    |   ✅   |   ❌   |  ❌  |
| Phone                |    ✅    |  ❌  |    ❌    |   ❌   |   ❌   |  ❌  |
| Activity Recognition |    ✅    |  ✅  |    ❌    |   ❌   |   ❌   |  ❌  |
| Nearby Devices       |    ✅    |  ✅  |    ❌    |   ❌   |   ❌   |  ❌  |
| Network              |    ✅    |  ✅  |    ✅    |   ✅   |   ✅   |  ✅  |

## Best Practices

1. **Always check permission status first** before performing sensitive operations
2. **Provide clear rationales** for why permissions are needed
3. **Handle all permission states** gracefully (granted, denied, settings, error)
4. **Use appropriate methods** for your use case:
   - `requestPermission()` for direct permission requests
   - `requestPermissionWithDialog()` for custom dialog experience
   - `checkPermissionStatus()` to verify current state
5. **Respect user choices** - don't repeatedly ask for denied permissions
6. **Use `openAppSettings()`** for permanent denials
7. **Test on both platforms** as permission behavior differs between Android and iOS

## Error Handling

The plugin returns different status enums:
- `PermissionStatus.granted`: Permission successfully obtained
- `PermissionStatus.denied`: Permission rejected by the user
- `PermissionStatus.openSettings`: Permanent denial, suggest manual settings
- `PermissionStatus.unsupported`: Permission not supported on current platform
- `PermissionStatus.error`: An error occurred during the permission request

## Common Android Permissions

Add these to your `android/app/src/main/AndroidManifest.xml` if needed:

```xml
<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Audio -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Bluetooth -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Contacts -->
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />

<!-- Phone -->
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- SMS -->
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />

<!-- Calendar -->
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Activity Recognition -->
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

<!-- Sensors -->
<uses-permission android:name="android.permission.BODY_SENSORS" />

<!-- WiFi -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />

<!-- Nearby Devices -->
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />

<!-- Alarms -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

## Common iOS Permissions

Add these to your `ios/Runner/Info.plist`:

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and videos</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save and select images</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based services</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based services</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>This app needs contacts access to import your contacts</string>

<!-- Calendar -->
<key>NSCalendarsUsageDescription</key>
<string>This app needs calendar access to manage your events</string>

<!-- Reminders -->
<key>NSRemindersUsageDescription</key>
<string>This app needs reminders access to manage your tasks</string>

<!-- Motion & Fitness -->
<key>NSMotionUsageDescription</key>
<string>This app needs motion access to track your activity</string>

<!-- Bluetooth -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to connect to peripheral devices</string>

<!-- Face ID -->
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>

<!-- Health -->
<key>NSHealthShareUsageDescription</key>
<string>This app needs health data access to track your fitness</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs health data access to update your fitness information</string>
```

## Platform-Specific Usage Examples

### Windows Platform

The Permission Master plugin provides comprehensive support for Windows platform permissions. Here are examples of how to use Windows-specific permissions:

#### Camera Permission (Windows)
```dart
import 'package:permission_master/permission_master.dart';

// Request camera permission on Windows
Future<void> requestWindowsCameraPermission() async {
  try {
    final result = await PermissionMaster.requestCameraPermissionWindows();
    print('Windows Camera Permission: $result');
    
    if (result == 'granted') {
      // Camera permission granted, proceed with camera operations
      print('Camera access granted on Windows');
    } else {
      // Permission denied, show appropriate message
      print('Camera permission denied on Windows');
    }
  } catch (e) {
    print('Error requesting Windows camera permission: $e');
  }
}
```

#### Microphone Permission (Windows)
```dart
// Request microphone permission on Windows
Future<void> requestWindowsMicrophonePermission() async {
  try {
    final result = await PermissionMaster.requestMicrophonePermissionWindows();
    print('Windows Microphone Permission: $result');
    
    if (result == 'granted') {
      // Microphone permission granted
      print('Microphone access granted on Windows');
    }
  } catch (e) {
    print('Error requesting Windows microphone permission: $e');
  }
}
```

#### Location Permission (Windows)
```dart
// Request location permission on Windows
Future<void> requestWindowsLocationPermission() async {
  try {
    final result = await PermissionMaster.requestLocationPermissionWindows();
    print('Windows Location Permission: $result');
    
    if (result == 'granted') {
      // Location permission granted
      print('Location access granted on Windows');
    }
  } catch (e) {
    print('Error requesting Windows location permission: $e');
  }
}
```

#### Open Windows App Settings
```dart
// Open Windows app settings
Future<void> openWindowsSettings() async {
  try {
    await PermissionMaster.openAppSettingsWindows();
    print('Windows app settings opened');
  } catch (e) {
    print('Error opening Windows app settings: $e');
  }
}
```

### macOS Platform

The plugin offers extensive macOS permission support with native integration:

#### Camera Permission (macOS)
```dart
// Request camera permission on macOS
Future<void> requestMacOSCameraPermission() async {
  try {
    final result = await PermissionMaster.requestCameraPermissionMac();
    print('macOS Camera Permission: $result');
    
    if (result == 'granted') {
      // Camera permission granted
      print('Camera access granted on macOS');
    } else if (result == 'denied') {
      // Permission denied, guide user to settings
      await PermissionMaster.openAppSettingsMac();
    }
  } catch (e) {
    print('Error requesting macOS camera permission: $e');
  }
}
```

#### Microphone Permission (macOS)
```dart
// Request microphone permission on macOS
Future<void> requestMacOSMicrophonePermission() async {
  try {
    final result = await PermissionMaster.requestMicrophonePermissionMac();
    print('macOS Microphone Permission: $result');
    
    if (result == 'granted') {
      print('Microphone access granted on macOS');
    }
  } catch (e) {
    print('Error requesting macOS microphone permission: $e');
  }
}
```

#### Location Permission (macOS)
```dart
// Request location permission on macOS
Future<void> requestMacOSLocationPermission() async {
  try {
    final result = await PermissionMaster.requestLocationPermissionMac();
    print('macOS Location Permission: $result');
    
    if (result == 'granted') {
      print('Location access granted on macOS');
    }
  } catch (e) {
    print('Error requesting macOS location permission: $e');
  }
}
```

#### Contacts Permission (macOS)
```dart
// Request contacts permission on macOS
Future<void> requestMacOSContactsPermission() async {
  try {
    final result = await PermissionMaster.requestContactsPermissionMac();
    print('macOS Contacts Permission: $result');
    
    if (result == 'granted') {
      print('Contacts access granted on macOS');
    }
  } catch (e) {
    print('Error requesting macOS contacts permission: $e');
  }
}
```

#### Calendar Permission (macOS)
```dart
// Request calendar permission on macOS
Future<void> requestMacOSCalendarPermission() async {
  try {
    final result = await PermissionMaster.requestCalendarPermissionMac();
    print('macOS Calendar Permission: $result');
    
    if (result == 'granted') {
      print('Calendar access granted on macOS');
    }
  } catch (e) {
    print('Error requesting macOS calendar permission: $e');
  }
}
```

#### Photo Library Permission (macOS)
```dart
// Request photo library permission on macOS
Future<void> requestMacOSPhotoLibraryPermission() async {
  try {
    final result = await PermissionMaster.requestPhotoLibraryPermissionMac();
    print('macOS Photo Library Permission: $result');
    
    if (result == 'granted') {
      print('Photo library access granted on macOS');
    }
  } catch (e) {
    print('Error requesting macOS photo library permission: $e');
  }
}
```

### Linux Platform

Linux platform support provides essential permission management:

#### Camera Permission (Linux)
```dart
// Request camera permission on Linux
Future<void> requestLinuxCameraPermission() async {
  try {
    final result = await PermissionMaster.requestCameraPermissionLinux();
    print('Linux Camera Permission: $result');
    
    if (result == 'granted') {
      print('Camera access granted on Linux');
    } else {
      print('Camera permission denied on Linux');
    }
  } catch (e) {
    print('Error requesting Linux camera permission: $e');
  }
}
```

#### Microphone Permission (Linux)
```dart
// Request microphone permission on Linux
Future<void> requestLinuxMicrophonePermission() async {
  try {
    final result = await PermissionMaster.requestMicrophonePermissionLinux();
    print('Linux Microphone Permission: $result');
    
    if (result == 'granted') {
      print('Microphone access granted on Linux');
    }
  } catch (e) {
    print('Error requesting Linux microphone permission: $e');
  }
}
```

#### Location Permission (Linux)
```dart
// Request location permission on Linux
Future<void> requestLinuxLocationPermission() async {
  try {
    final result = await PermissionMaster.requestLocationPermissionLinux();
    print('Linux Location Permission: $result');
    
    if (result == 'granted') {
      print('Location access granted on Linux');
    }
  } catch (e) {
    print('Error requesting Linux location permission: $e');
  }
}
```

#### Storage Permission (Linux)
```dart
// Request storage permission on Linux
Future<void> requestLinuxStoragePermission() async {
  try {
    final result = await PermissionMaster.requestStoragePermissionLinux();
    print('Linux Storage Permission: $result');
    
    if (result == 'granted') {
      print('Storage access granted on Linux');
    }
  } catch (e) {
    print('Error requesting Linux storage permission: $e');
  }
}
```

#### Network Permission (Linux)
```dart
// Request network permission on Linux
Future<void> requestLinuxNetworkPermission() async {
  try {
    final result = await PermissionMaster.requestNetworkPermissionLinux();
    print('Linux Network Permission: $result');
    
    if (result == 'granted') {
      print('Network access granted on Linux');
    }
  } catch (e) {
    print('Error requesting Linux network permission: $e');
  }
}
```

#### Bluetooth Permission (Linux)
```dart
// Request Bluetooth permission on Linux
Future<void> requestLinuxBluetoothPermission() async {
  try {
    final result = await PermissionMaster.requestBluetoothPermissionLinux();
    print('Linux Bluetooth Permission: $result');
    
    if (result == 'granted') {
      print('Bluetooth access granted on Linux');
    }
  } catch (e) {
    print('Error requesting Linux Bluetooth permission: $e');
  }
}
```

### Web Platform

Web platform permissions are handled through browser APIs:

#### Camera Permission (Web)
```dart
// Request camera permission on Web
Future<void> requestWebCameraPermission() async {
  try {
    final result = await PermissionMaster.requestCameraPermissionWeb();
    print('Web Camera Permission: $result');
    
    if (result == 'granted') {
      print('Camera access granted on Web');
      // You can now access the camera through MediaDevices API
    } else if (result == 'denied') {
      print('Camera permission denied by user');
    } else if (result == 'prompt') {
      print('Camera permission prompt shown to user');
    }
  } catch (e) {
    print('Error requesting Web camera permission: $e');
  }
}
```

#### Microphone Permission (Web)
```dart
// Request microphone permission on Web
Future<void> requestWebMicrophonePermission() async {
  try {
    final result = await PermissionMaster.requestMicrophonePermissionWeb();
    print('Web Microphone Permission: $result');
    
    if (result == 'granted') {
      print('Microphone access granted on Web');
    }
  } catch (e) {
    print('Error requesting Web microphone permission: $e');
  }
}
```

#### Location Permission (Web)
```dart
// Request location permission on Web
Future<void> requestWebLocationPermission() async {
  try {
    final result = await PermissionMaster.requestLocationPermissionWeb();
    print('Web Location Permission: $result');
    
    if (result == 'granted') {
      print('Location access granted on Web');
      // You can now use Geolocation API
    }
  } catch (e) {
    print('Error requesting Web location permission: $e');
  }
}
```

#### Notification Permission (Web)
```dart
// Request notification permission on Web
Future<void> requestWebNotificationPermission() async {
  try {
    final result = await PermissionMaster.requestNotificationPermissionWeb();
    print('Web Notification Permission: $result');
    
    if (result == 'granted') {
      print('Notification access granted on Web');
      // You can now send notifications
    }
  } catch (e) {
    print('Error requesting Web notification permission: $e');
  }
}
```

#### Persistent Storage Permission (Web)
```dart
// Request persistent storage permission on Web
Future<void> requestWebPersistentStoragePermission() async {
  try {
    final result = await PermissionMaster.requestPersistentStoragePermissionWeb();
    print('Web Persistent Storage Permission: $result');
    
    if (result == 'granted') {
      print('Persistent storage access granted on Web');
    }
  } catch (e) {
    print('Error requesting Web persistent storage permission: $e');
  }
}
```

### Platform Detection and Conditional Usage

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_master/permission_master.dart';

// Example of platform-specific permission handling
Future<void> requestCameraPermissionForCurrentPlatform() async {
  try {
    String result;
    
    if (kIsWeb) {
      // Web platform
      result = await PermissionMaster.requestCameraPermissionWeb();
      print('Web camera permission: $result');
    } else if (Platform.isWindows) {
      // Windows platform
      result = await PermissionMaster.requestCameraPermissionWindows();
      print('Windows camera permission: $result');
    } else if (Platform.isMacOS) {
      // macOS platform
      result = await PermissionMaster.requestCameraPermissionMac();
      print('macOS camera permission: $result');
    } else if (Platform.isLinux) {
      // Linux platform
      result = await PermissionMaster.requestCameraPermissionLinux();
      print('Linux camera permission: $result');
    } else {
      // Android/iOS - use standard permission methods
      result = await PermissionMaster.requestPermission(PermissionType.camera);
      print('Mobile camera permission: $result');
    }
    
    // Handle the result
    if (result == 'granted') {
      print('Camera permission granted on current platform');
      // Proceed with camera operations
    } else {
      print('Camera permission denied on current platform');
      // Show appropriate message or guide user to settings
    }
  } catch (e) {
    print('Error requesting camera permission: $e');
  }
}
```

### Complete Platform-Specific Example

```dart
import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformSpecificPermissionExample extends StatefulWidget {
  @override
  _PlatformSpecificPermissionExampleState createState() => _PlatformSpecificPermissionExampleState();
}

class _PlatformSpecificPermissionExampleState extends State<PlatformSpecificPermissionExample> {
  String _permissionStatus = 'Unknown';
  String _currentPlatform = 'Unknown';

  @override
  void initState() {
    super.initState();
    _detectPlatform();
  }

  void _detectPlatform() {
    if (kIsWeb) {
      _currentPlatform = 'Web';
    } else if (Platform.isWindows) {
      _currentPlatform = 'Windows';
    } else if (Platform.isMacOS) {
      _currentPlatform = 'macOS';
    } else if (Platform.isLinux) {
      _currentPlatform = 'Linux';
    } else if (Platform.isAndroid) {
      _currentPlatform = 'Android';
    } else if (Platform.isIOS) {
      _currentPlatform = 'iOS';
    }
    setState(() {});
  }

  Future<void> _requestCameraPermission() async {
    try {
      String result;
      
      if (kIsWeb) {
        result = await PermissionMaster.requestCameraPermissionWeb();
      } else if (Platform.isWindows) {
        result = await PermissionMaster.requestCameraPermissionWindows();
      } else if (Platform.isMacOS) {
        result = await PermissionMaster.requestCameraPermissionMac();
      } else if (Platform.isLinux) {
        result = await PermissionMaster.requestCameraPermissionLinux();
      } else {
        result = await PermissionMaster.requestPermission(PermissionType.camera);
      }
      
      setState(() {
        _permissionStatus = result;
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _openAppSettings() async {
    try {
      if (kIsWeb) {
        // Web doesn't have app settings, show browser settings info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please check browser settings for permissions')),
        );
      } else if (Platform.isWindows) {
        await PermissionMaster.openAppSettingsWindows();
      } else if (Platform.isMacOS) {
        await PermissionMaster.openAppSettingsMac();
      } else if (Platform.isLinux) {
        await PermissionMaster.openAppSettingsLinux();
      } else {
        await PermissionMaster.openAppSettings();
      }
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform-Specific Permissions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Platform: $_currentPlatform',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Camera Permission Status: $_permissionStatus',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: Text('Request Camera Permission'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openAppSettings,
              child: Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Additional Information

If you have any issues, questions, or suggestions related to this package, please feel free to contact us at [swan.dev1993@gmail.com](mailto:swan.dev1993@gmail.com). We welcome your feedback and will do our best to address any problems or provide assistance.

For more information about this package, you can also visit our [GitHub repository](https://github.com/SwanFlutter/permission_master) where you can find additional resources, contribute to the package's development, and file issues or bug reports.

Thank you for using our package, and we look forward to hearing from you!
