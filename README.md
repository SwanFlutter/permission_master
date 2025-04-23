Here's the revised and complete documentation for the Permission Master Flutter plugin, incorporating the use of the `PermissionStatus` enum for better readability and maintainability:

---

# Permission Master Flutter Plugin

## Overview

Permission Master is a comprehensive Flutter plugin designed to simplify permission management across iOS and Android platforms. It provides an intuitive and easy-to-use interface for requesting and checking various system permissions while ensuring a smooth user experience.

## Key Features

- Simplified permission request methods
- Granular permission control
- Context-aware permission dialogs
- Platform-agnostic API
- No manual `AndroidManifest.xml` configuration required

iOS platform requirement (iOS 12.0 and above)
Supported platform Android (5.0 to 15)

![Screenshot 2025-04-23 084659](https://github.com/user-attachments/assets/56d4dc2c-bc42-4124-abe0-592b092c7ae1)



## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  permission_master: ^0.0.1
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

```dart
Future<void> requestCameraAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestCameraPermission();

  if (status == PermissionStatus.granted) {
    // Camera access allowed
    // Proceed with camera-related functionality
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    // Handle permission denial
    print('Camera permission denied');
  }
}
```

### 2. Location Permission

```dart
Future<void> requestLocationAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestLocationPermission();

  switch (status) {
    case PermissionStatus.granted:
      // Location access allowed
      // Start location services
      break;
    case PermissionStatus.denied:
      // User rejected location permission
      break;
    case PermissionStatus.openSettings:
      // Permanent denial, suggest opening app settings
      await permissionMaster.openAppSettings();
      break;
    default:
      // Handle error
      print('Error requesting location permission');
  }
}
```

### 3. Storage Permission

```dart
Future<void> requestStorageAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestStoragePermission();

  if (status == PermissionStatus.granted) {
    // Read/write files allowed
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Storage permission not granted');
  }
}
```

### 4. Microphone Permission

```dart
Future<void> requestMicrophoneAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestMicrophonePermission();

  if (status == PermissionStatus.granted) {
    // Start audio recording
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    // Handle microphone access denial
  }
}
```

### 5. Bluetooth Permission

```dart
Future<void> requestBluetoothAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestBluetoothPermission();

  if (status == PermissionStatus.granted) {
    // Enable Bluetooth functionality
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Bluetooth permission denied');
  }
}
```

### 6. Contacts Permission

```dart
Future<void> requestContactsAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestContactsPermission();

  if (status == PermissionStatus.granted) {
    // Access contacts
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Contacts permission denied');
  }
}
```

### 7. Notifications Permission

```dart
Future<void> requestNotificationsAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestNotificationPermission();

  if (status == PermissionStatus.granted) {
    // Send notifications
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Notifications permission denied');
  }
}
```

### 8. SMS Permission

```dart
Future<void> requestSmsAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestSmsPermission();

  if (status == PermissionStatus.granted) {
    // Access SMS
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('SMS permission denied');
  }
}
```

### 9. Calendar Permission

```dart
Future<void> requestCalendarAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestCalendarPermission();

  if (status == PermissionStatus.granted) {
    // Access calendar
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Calendar permission denied');
  }
}
```

### 10. Phone Permission

```dart
Future<void> requestPhoneAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestPhonePermission();

  if (status == PermissionStatus.granted) {
    // Access phone features
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Phone permission denied');
  }
}
```

### 11. Activity Recognition Permission

```dart
Future<void> requestActivityRecognitionAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestActivityRecognitionPermission();

  if (status == PermissionStatus.granted) {
    // Access activity recognition
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Activity recognition permission denied');
  }
}
```

### 12. Nearby Devices Permission

```dart
Future<void> requestNearbyDevicesAccess() async {
  final permissionMaster = PermissionMaster();
  final status = await permissionMaster.requestNearbyDevicesPermission();

  if (status == PermissionStatus.granted) {
    // Access nearby devices
  } else if (status == PermissionStatus.openSettings) {
    // Permanent denial, suggest opening app settings
    await permissionMaster.openAppSettings();
  } else {
    print('Nearby devices permission denied');
  }
}
```

### 13. Multiple Permission Checking

```dart
Future<void> checkMultiplePermissions() async {
  final permissionMaster = PermissionMaster();
  final statuses = await permissionMaster.checkMultiplePermissions([
    PermissionType.camera,
    PermissionType.location,
    PermissionType.microphone
  ]);

  statuses.forEach((permission, status) {
    print('$permission status: $status');
    if (status == PermissionStatus.openSettings) {
      // Suggest opening app settings for permanently denied permissions
      permissionMaster.openAppSettings();
    }
  });
}
```

### 14. Open App Settings

```dart
Future<void> openAppPermissionSettings() async {
  final permissionMaster = PermissionMaster();
  await permissionMaster.openAppSettings();
}
```

### Custom Permission For Use UI

```dart
ElevatedButton(
  onPressed: () async {
    await permissionMaster.grantedRequestPermission(PermissionType.camera);
  },
  child: Text('Request Camera Permission'),
)
```

```dart
ElevatedButton(
  onPressed: () async {
    await permissionMaster.denyRequestPermission(permission: PermissionType.camera);
    print("DENIED");
    Navigator.pop(context);
  },
  child: Text('Deny Camera Permission'),
)
```

```dart
ElevatedButton(
  onPressed: () async {
    await permissionMaster.openAppSettingsDirectly();
    print("App settings opened");
  },
  child: Text("Open App Settings"),
)
```

### Get Platform Version

- Example

```dart
String? platformVersion;

Text("$platformVersion", style: TextStyle(fontSize: 24.0)),
// Android 13
ElevatedButton(
  onPressed: () async {
    String version = (await permissionMaster.getPlatformVersion())!;
    setState(() {
      platformVersion = version;
    });
    print(platformVersion);
  },
  child: Text("Get platform version"),
)
```

## Supported Permissions

| Permission Type       | Android | iOS |
|----------------------|---------|-----|
| Camera               | ✅      | ✅  |
| Location             | ✅      | ✅  |
| Storage              | ✅      | ✅  |
| Microphone           | ✅      | ✅  |
| Bluetooth            | ✅      | ✅  |
| Contacts             | ✅      | ✅  |
| Notifications        | ✅      | ✅  |
| SMS                  | ✅      | ❌  |
| Calendar             | ✅      | ✅  |
| Phone                | ✅      | ❌  |
| Activity Recognition | ✅      | ✅  |
| Nearby Devices       | ✅      | ✅  |

## Best Practices

1. Always check permission status before performing sensitive operations.
2. Provide clear rationales for why permissions are needed.
3. Gracefully handle permission denials.
4. Use `openAppSettings()` for permanent denials.
5. Use `checkMultiplePermissions()` to handle multiple permissions at once.

## Error Handling

The plugin returns different status enums:
- `PermissionStatus.granted`: Permission successfully obtained.
- `PermissionStatus.denied`: Permission rejected by the user.
- `PermissionStatus.openSettings`: Permanent denial, suggest manual settings.
- `PermissionStatus.error`: An error occurred during the permission request.

## Conclusion

Permission Master simplifies cross-platform permission management in Flutter, providing a clean, intuitive API for handling various system permissions with minimal configuration.
It ensures a smooth user experience by handling edge cases like permanent denials and providing easy access to app settings for manual permission management.
