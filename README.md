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
  permission_master: ^0.0.13
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

بسیار عذر می‌خواهم بابت سوءتفاهم. متوجه شدم که تاکید شما روی بازنویسی کامل بخش‌های مربوط به پلتفرم‌های دسکتاپ و وب با مثال‌های مجزا و به زبان انگلیسی برای هر متد بود.

لطفاً این نسخه اصلاح‌شده را بررسی کنید.

-----

## Platform-Specific Usage Examples

This section provides detailed examples for using `PermissionMaster` on each specific platform, including Windows, macOS, Linux, and Web. Each method is demonstrated with a dedicated code snippet.

### Windows Platform

To manage permissions on Windows, use the following methods.

#### 1\. Request Camera Permission

```dart
Future<void> requestWindowsCameraPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestCameraPermissionWindows();

  if (status == 'granted') {
    print('Windows camera permission granted');
  } else {
    print('Windows camera permission denied or an error occurred: $status');
  }
}
```

#### 2\. Request Microphone Permission

```dart
Future<void> requestWindowsMicrophonePermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestMicrophonePermissionWindows();

  if (status == 'granted') {
    print('Windows microphone permission granted');
  } else {
    print('Windows microphone permission denied or an error occurred: $status');
  }
}
```

#### 3\. Request Location Permission

```dart
Future<void> requestWindowsLocationPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestLocationPermissionWindows();

  if (status == 'granted') {
    print('Windows location permission granted');
  } else {
    print('Windows location permission denied or an error occurred: $status');
  }
}
```

#### 4\. Request Notification Permission

```dart
Future<void> requestWindowsNotificationPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestNotificationPermissionWindows();

  if (status == 'granted') {
    print('Windows notification permission granted');
  } else {
    print('Windows notification permission denied or an error occurred: $status');
  }
}
```

#### 5\. Check Camera Permission Status

```dart
Future<void> checkWindowsCameraPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.checkCameraPermissionWindows();
  print('Current Windows camera permission status: $status');
}
```

#### 6\. Check Microphone Permission Status

```dart
Future<void> checkWindowsMicrophonePermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.checkMicrophonePermissionWindows();
  print('Current Windows microphone permission status: $status');
}
```

#### 7\. Check Location Permission Status

```dart
Future<void> checkWindowsLocationPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.checkLocationPermissionWindows();
  print('Current Windows location permission status: $status');
}
```

#### 8\. Open Windows App Settings

```dart
Future<void> openWindowsSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettingsWindows();
  print('Attempted to open Windows app settings.');
}
```

#### 9\. Open Windows Camera Settings

```dart
Future<void> openWindowsCameraSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openCameraSettingsWindows();
  print('Attempted to open Windows camera settings.');
}
```

#### 10\. Open Windows Microphone Settings

```dart
Future<void> openWindowsMicrophoneSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openMicrophoneSettingsWindows();
  print('Attempted to open Windows microphone settings.');
}
```

-----

### macOS Platform

For macOS, the plugin provides a rich set of methods to handle native permissions.

#### 1\. Request Camera Permission

```dart
Future<void> requestMacOSCameraPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestCameraPermissionMac();

  if (status == 'granted') {
    print('macOS camera permission granted');
  } else if (status == 'denied') {
    print('macOS camera permission was denied by the user.');
  }
}
```

#### 2\. Request Microphone Permission

```dart
Future<void> requestMacOSMicrophonePermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestMicrophonePermissionMac();

  if (status == 'granted') {
    print('macOS microphone permission granted');
  } else {
    print('macOS microphone permission denied or an error occurred: $status');
  }
}
```

#### 3\. Request Photo Library Permission

```dart
Future<void> requestMacOSPhotoLibraryPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestPhotoLibraryPermissionMac();

  if (status == 'granted') {
    print('macOS photo library permission granted');
  } else {
    print('macOS photo library permission denied or an error occurred: $status');
  }
}
```

#### 4\. Request Contacts Permission

```dart
Future<void> requestMacOSContactsPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestContactsPermissionMac();

  if (status == 'granted') {
    print('macOS contacts permission granted');
  } else {
    print('macOS contacts permission denied or an error occurred: $status');
  }
}
```

#### 5\. Request Calendar Permission

```dart
Future<void> requestMacOSCalendarPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestCalendarPermissionMac();

  if (status == 'granted') {
    print('macOS calendar permission granted');
  } else {
    print('macOS calendar permission denied or an error occurred: $status');
  }
}
```

#### 6\. Check Photo Library Permission Status

```dart
Future<void> checkMacOSPhotoPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.checkPhotoLibraryPermissionMac();
  print('Current macOS photo library permission status: $status');
}
```

#### 7\. Open macOS App Settings

```dart
Future<void> openMacOSSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettingsMac();
  print('Attempted to open macOS app settings in System Settings.');
}
```

-----

### Linux Platform

For Linux distributions, you can manage core hardware permissions.

#### 1\. Request Camera Permission

```dart
Future<void> requestLinuxCameraPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestCameraPermissionLinux();

  if (status == 'granted') {
    print('Linux camera permission granted');
  } else {
    print('Linux camera permission denied or not available: $status');
  }
}
```

#### 2\. Request Microphone Permission

```dart
Future<void> requestLinuxMicrophonePermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestMicrophonePermissionLinux();

  if (status == 'granted') {
    print('Linux microphone permission granted');
  } else {
    print('Linux microphone permission denied or not available: $status');
  }
}
```

#### 3\. Request Storage Permission

```dart
Future<void> requestLinuxStoragePermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestStoragePermissionLinux();

  if (status == 'granted') {
    print('Linux storage access granted');
  } else {
    print('Linux storage access denied or not available: $status');
  }
}
```

#### 4\. Request Bluetooth Permission

```dart
Future<void> requestLinuxBluetoothPermission() async {
  final permissionMaster = PermissionMaster();
  final String status = await permissionMaster.requestBluetoothPermissionLinux();

  if (status == 'granted') {
    print('Linux Bluetooth permission granted');
  } else {
    print('Linux Bluetooth permission denied or not available: $status');
  }
}
```

#### 5\. Open Linux App Settings

```dart
Future<void> openLinuxSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettingsLinux();
  print('Attempted to open Linux system settings.');
}
```

-----

### Web Platform

For web applications, you must create an instance of `PermissionMasterWeb`. Permissions are handled via browser APIs and typically require a secure context (HTTPS).

#### 1\. Request Camera Permission

```dart
Future<void> requestWebCameraPermission() async {
  PermissionMasterWeb permissionMasterWeb = PermissionMasterWeb();
  final String status = await permissionMasterWeb.requestCameraPermissionWeb();

  if (status == 'granted') {
    print('Web camera permission granted');
  } else if (status == 'denied') {
    print('Web camera permission was denied by the user.');
  } else {
    print('Web camera is not supported or an error occurred: $status');
  }
}
```

#### 2\. Request Microphone Permission

```dart
Future<void> requestWebMicrophonePermission() async {
  PermissionMasterWeb permissionMasterWeb = PermissionMasterWeb();
  final String status = await permissionMasterWeb.requestMicrophonePermissionWeb();

  if (status == 'granted') {
    print('Web microphone permission granted');
  } else if (status == 'denied') {
    print('Web microphone permission was denied by the user.');
  } else {
    print('Web microphone is not supported or an error occurred: $status');
  }
}
```

#### 3\. Request Location Permission

```dart
Future<void> requestWebLocationPermission() async {
  PermissionMasterWeb permissionMasterWeb = PermissionMasterWeb();
  final String status = await permissionMasterWeb.requestLocationPermissionWeb();

  if (status == 'granted') {
    print('Web location permission granted');
  } else if (status == 'denied') {
    print('Web location permission was denied by the user.');
  } else {
    print('Web location is not supported or an error occurred: $status');
  }
}
```

#### 4\. Request Notification Permission

```dart
Future<void> requestWebNotificationPermission() async {
  PermissionMasterWeb permissionMasterWeb = PermissionMasterWeb();
  final String status = await permissionMasterWeb.requestNotificationPermissionWeb();

  if (status == 'granted') {
    print('Web notification permission granted');
  } else if (status == 'denied') {
    print('Web notification permission was denied by the user.');
  } else {
    print('Web notifications are not supported or an error occurred: $status');
  }
}
```

#### 5\. Open Settings (Web)

This method does not open a native settings screen. Instead, it shows a browser alert guiding the user to change permissions manually.

```dart
Future<void> openWebSettings() async {
  PermissionMasterWeb permissionMasterWeb = PermissionMasterWeb();
  await permissionMasterWeb.openAppSettings();
  // This will show a browser alert to the user.
}
```

## Additional Information

If you have any issues, questions, or suggestions related to this package, please feel free to contact us at [swan.dev1993@gmail.com](mailto:swan.dev1993@gmail.com). We welcome your feedback and will do our best to address any problems or provide assistance.

For more information about this package, you can also visit our [GitHub repository](https://github.com/SwanFlutter/permission_master) where you can find additional resources, contribute to the package's development, and file issues or bug reports.

Thank you for using our package, and we look forward to hearing from you!
