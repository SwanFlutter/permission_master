# Android Permissions Configuration Guide

## Overview
این سند توضیح می‌دهد که کدام permission های Android در پروژه پیاده‌سازی شده‌اند و چگونه کار می‌کنند.

---

## ✅ Permission های پیاده‌سازی شده در Android

### 1. **Camera Permission** 🎥
- **Android Permission:** `android.permission.CAMERA`
- **Method:** `requestCameraPermission()`
- **توضیح:** برای دسترسی به دوربین دستگاه
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestCameraPermission();
  ```

### 2. **Photos/Storage Permission** 📸
- **Android Permissions:**
  - Android 13+ (API 33+): 
    - `READ_MEDIA_IMAGES`
    - `READ_MEDIA_VIDEO`
    - `READ_MEDIA_AUDIO`
  - Android 11-12 (API 30-32): `READ_EXTERNAL_STORAGE`
  - Android 6-10 (API 23-29): 
    - `READ_EXTERNAL_STORAGE`
    - `WRITE_EXTERNAL_STORAGE`
- **Method:** `requestStoragePermission()`
- **توضیح:** برای دسترسی به فایل‌ها و رسانه‌ها
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestStoragePermission();
  ```

### 3. **Microphone Permission** 🎤
- **Android Permission:** `android.permission.RECORD_AUDIO`
- **Method:** `requestMicrophonePermission()`
- **توضیح:** برای ضبط صدا و استفاده از میکروفون
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestMicrophonePermission();
  ```

### 4. **Location Permission** 📍
- **Android Permissions:**
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
- **Method:** `requestLocationPermission()`
- **توضیح:** برای دسترسی به موقعیت مکانی دقیق و تقریبی
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestLocationPermission();
  ```

### 5. **Contacts Permission** 👥
- **Android Permission:** `android.permission.READ_CONTACTS`
- **Method:** `requestContactsPermission()`
- **توضیح:** برای خواندن مخاطبین
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestContactsPermission();
  ```

### 6. **Calendar Permission** 📅
- **Android Permission:** `android.permission.READ_CALENDAR`
- **Method:** `requestCalendarPermission()`
- **توضیح:** برای خواندن رویدادهای تقویم
- **نکته:** در Android، Reminders جزئی از Calendar است
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestCalendarPermission();
  ```

### 7. **Notifications Permission** 🔔
- **Android Permission:** `android.permission.POST_NOTIFICATIONS` (Android 13+)
- **Method:** `requestNotificationPermission()`
- **توضیح:** برای ارسال اعلان‌ها (فقط Android 13 به بالا)
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestNotificationPermission();
  ```

### 8. **Bluetooth Permission** 📶
- **Android Permissions:**
  - Android 12+ (API 31+):
    - `BLUETOOTH_SCAN`
    - `BLUETOOTH_CONNECT`
    - `BLUETOOTH_ADVERTISE`
  - Android 11 و پایین‌تر: نیاز به permission ندارد
- **Method:** `requestBluetoothPermission()`
- **توضیح:** برای اسکن و اتصال به دستگاه‌های بلوتوث
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestBluetoothPermission();
  ```

### 9. **Motion/Activity Recognition Permission** 🏃
- **Android Permission:** 
  - `android.permission.ACTIVITY_RECOGNITION` (Android 10+)
  - `android.permission.BODY_SENSORS` (Android 4.4+)
- **Methods:** 
  - `requestActivityRecognitionPermission()`
  - `requestSensorsPermission()`
- **توضیح:** برای تشخیص فعالیت و دسترسی به سنسورهای بدن
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestActivityRecognitionPermission();
  ```

### 10. **SMS Permission** 📱
- **Android Permission:** `android.permission.SEND_SMS`
- **Method:** `requestSmsPermission()`
- **توضیح:** برای ارسال پیامک
- **نکته:** فقط در Android موجود است
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestSmsPermission();
  ```

### 11. **Phone Permission** 📞
- **Android Permission:** `android.permission.READ_PHONE_STATE`
- **Method:** `requestPhonePermission()`
- **توضیح:** برای خواندن وضعیت تلفن
- **نکته:** فقط در Android موجود است
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestPhonePermission();
  ```

### 12. **WiFi Permission** 📡
- **Android Permission:** `android.permission.ACCESS_WIFI_STATE`
- **Method:** `requestWifiPermission()`
- **توضیح:** برای دسترسی به وضعیت WiFi
- **نکته:** فقط در Android موجود است
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestWifiPermission();
  ```

### 13. **Nearby Devices Permission** 🔍
- **Android Permission:** `android.permission.NEARBY_WIFI_DEVICES` (Android 12+)
- **Method:** `requestNearbyDevicesPermission()`
- **توضیح:** برای کشف دستگاه‌های نزدیک
- **نکته:** فقط در Android 12 به بالا
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestNearbyDevicesPermission();
  ```

### 14. **Alarm Permission** ⏰
- **Android Permission:** `android.permission.SCHEDULE_EXACT_ALARM` (Android 12+)
- **Method:** `requestAlarmPermission()`
- **توضیح:** برای تنظیم آلارم‌های دقیق
- **نکته:** فقط در Android 12 به بالا
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestAlarmPermission();
  ```

### 15. **Health Permission** ❤️
- **Android API:** Health Connect (Android 14+)
- **Method:** `requestHealthPermission()`
- **توضیح:** برای دسترسی به داده‌های سلامتی از طریق Health Connect
- **نکته:** 
  - فقط در Android 14 (API 34) به بالا
  - نیاز به نصب Health Connect app دارد
  - از Intent برای باز کردن تنظیمات Health Connect استفاده می‌کند
- **مثال استفاده:**
  ```dart
  final status = await permissionMaster.requestHealthPermission();
  ```

---

## ⚠️ Permission های غیرموجود در Android

این permission ها در iOS موجود هستند اما در Android معادل مستقیم ندارند:

### 1. **Reminders Permission** ⏰
- **وضعیت:** در Android جزئی از Calendar است
- **راه حل:** از `requestCalendarPermission()` استفاده کنید
- **توضیح:** Android یادآورها را در Calendar ذخیره می‌کند

### 2. **Speech Recognition Permission** 🗣️
- **وضعیت:** نیاز به permission خاصی ندارد
- **راه حل:** از `requestMicrophonePermission()` استفاده کنید
- **توضیح:** Speech Recognition در Android فقط به Microphone نیاز دارد

### 3. **Music Library Permission** 🎵
- **وضعیت:** نیاز به permission خاصی ندارد
- **راه حل:** از `requestStoragePermission()` استفاده کنید
- **توضیح:** Android از MediaStore استفاده می‌کند که نیاز به permission جداگانه ندارد

### 4. **Health Permission** ❤️
- **وضعیت:** ✅ از Android 14 پشتیبانی می‌شود
- **راه حل:** از `requestHealthPermission()` استفاده کنید
- **توضیح:** Android 14+ از Health Connect استفاده می‌کند
- **نکته:** نیاز به نصب Health Connect app دارد

---

## 📋 AndroidManifest.xml Configuration

### موقعیت فایل:
```
android/src/main/AndroidManifest.xml
```

### Permission های مورد نیاز:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.camera" android:required="false" />
    
    <!-- Storage/Photos -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="29" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    
    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Microphone -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <!-- Contacts -->
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
    
    <!-- Calendar -->
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />
    
    <!-- Notifications (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Bluetooth -->
    <uses-permission android:name="android.permission.BLUETOOTH" 
                     android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
                     android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
    
    <!-- Activity Recognition -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    
    <!-- Body Sensors -->
    <uses-permission android:name="android.permission.BODY_SENSORS" />
    
    <!-- SMS -->
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    
    <!-- Phone -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    
    <!-- WiFi -->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    
    <!-- Nearby Devices (Android 12+) -->
    <uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />
    
    <!-- Alarm (Android 12+) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    
    <!-- Health Connect (Android 14+) -->
    <!-- Health Connect uses a separate permission system through Health Connect API -->
    <!-- No manifest permission needed, but Health Connect app must be installed -->
    
</manifest>
```

---

## 🔧 Version-Specific Permissions

Android permission ها بر اساس نسخه SDK متفاوت هستند:

| Permission | Min SDK | Max SDK | توضیح |
|-----------|---------|---------|-------|
| WRITE_EXTERNAL_STORAGE | 23 | 29 | فقط Android 6-10 |
| READ_EXTERNAL_STORAGE | 23 | 32 | فقط Android 6-12 |
| READ_MEDIA_* | 33 | - | فقط Android 13+ |
| POST_NOTIFICATIONS | 33 | - | فقط Android 13+ |
| BLUETOOTH_SCAN/CONNECT | 31 | - | فقط Android 12+ |
| ACTIVITY_RECOGNITION | 29 | - | فقط Android 10+ |
| NEARBY_WIFI_DEVICES | 31 | - | فقط Android 12+ |
| SCHEDULE_EXACT_ALARM | 31 | - | فقط Android 12+ |
| Health Connect | 34 | - | فقط Android 14+ |

---

## 📊 خلاصه مقایسه iOS vs Android

| Permission | iOS | Android | یادداشت |
|-----------|-----|---------|---------|
| 📷 Camera | ✅ | ✅ | هر دو |
| 🖼️ Photos | ✅ | ✅ | هر دو |
| 🎤 Microphone | ✅ | ✅ | هر دو |
| 📍 Location | ✅ | ✅ | هر دو |
| 👥 Contacts | ✅ | ✅ | هر دو |
| 📅 Calendar | ✅ | ✅ | هر دو |
| ⏰ Reminders | ✅ | ⚠️ | Android: جزء Calendar |
| 🔔 Notifications | ✅ | ✅ | هر دو |
| 📶 Bluetooth | ✅ | ✅ | هر دو |
| 🏃 Motion | ✅ | ✅ | هر دو |
| 🗣️ Speech | ✅ | ⚠️ | Android: جزء Microphone |
| 🎵 Music | ✅ | ⚠️ | Android: نیاز به permission ندارد |
| ❤️ Health | ✅ | ✅ | Android 14+ (Health Connect) |
| 📱 SMS | ❌ | ✅ | فقط Android |
| 📞 Phone | ❌ | ✅ | فقط Android |
| 📡 WiFi | ❌ | ✅ | فقط Android |
| 🔍 Nearby | ❌ | ✅ | فقط Android |
| ⏰ Alarm | ❌ | ✅ | فقط Android |

---

## 🚀 نتیجه‌گیری

Android در حال حاضر **15 permission اصلی** را پشتیبانی می‌کند که 5 مورد آن فقط در Android موجود است (SMS, Phone, WiFi, Nearby Devices, Alarm).

Permission های iOS که در Android معادل مستقیم ندارند:
- **Reminders**: از Calendar استفاده کنید
- **Speech Recognition**: از Microphone استفاده کنید  
- **Music Library**: نیاز به permission ندارد

**نکته مهم:** Health Permission از Android 14 (API 34) پشتیبانی می‌شود و از Health Connect API استفاده می‌کند.
