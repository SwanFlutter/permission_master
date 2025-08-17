# راه‌اندازی سریع Permission Master

## مرحله 1: نصب پکیج
```yaml
dependencies:
  permission_master: ^latest_version
```

## مرحله 2: اضافه کردن پرمیشن‌های مورد نیاز

### Android (android/app/src/main/AndroidManifest.xml)
فقط پرمیشن‌های مورد نیاز خود را اضافه کنید:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS (ios/Runner/Info.plist)
فقط کلیدهای مورد نیاز خود را اضافه کنید:
```xml
<key>NSCameraUsageDescription</key>
<string>توضیحات استفاده از دوربین</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>توضیحات استفاده از لوکیشن</string>
```

## مرحله 3: استفاده در کد

```dart
import 'package:permission_master/permission_master.dart';

// تنظیم context
PermissionMaster.setContext(context);

// استفاده ساده
final permissionMaster = PermissionMaster();

// درخواست دوربین
final status = await permissionMaster.requestCameraPermission();

// یا استفاده عمومی
final status = await permissionMaster.requestPermission(
  permission: PermissionType.camera,
);
```

## پرمیشن‌های پشتیبانی شده

### Android
- CAMERA
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- RECORD_AUDIO
- READ_CONTACTS
- BLUETOOTH
- BODY_SENSORS
- و...

### iOS
- NSCameraUsageDescription
- NSLocationWhenInUseUsageDescription
- NSPhotoLibraryUsageDescription
- NSMicrophoneUsageDescription
- NSContactsUsageDescription
- و...

برای لیست کامل به فایل PERMISSION_GUIDE.md مراجعه کنید.