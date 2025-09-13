Here’s the English version of your "Quick Setup for Permission Master" guide:

---

# Quick Setup: Permission Master

## Step 1: Install the Package
Add the following to your `pubspec.yaml`:
```yaml
dependencies:
  permission_master: ^latest_version
```

## Step 2: Add Required Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
Add only the permissions you need:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
Add only the keys you need:
```xml
<key>NSCameraUsageDescription</key>
<string>Description for camera usage</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Description for location usage</string>
```

## Step 3: Usage in Code
```dart
import 'package:permission_master/permission_master.dart';

// Set context
PermissionMaster.setContext(context);

// Simple usage
final permissionMaster = PermissionMaster();

// Request camera permission
final status = await permissionMaster.requestCameraPermission();

// Or use the general method
final status = await permissionMaster.requestPermission(
  permission: PermissionType.camera,
);
```

## Supported Permissions

### Android
- `CAMERA`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`
- `RECORD_AUDIO`
- `READ_CONTACTS`
- `BLUETOOTH`
- `BODY_SENSORS`
- And more...

### iOS
- `NSCameraUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSContactsUsageDescription`
- And more...

For a complete list, refer to the `PERMISSION_GUIDE.md` file.