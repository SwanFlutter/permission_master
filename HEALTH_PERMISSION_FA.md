# راهنمای مجوز سلامتی (Health Permission)

## خلاصه

مجوز سلامتی به اپلیکیشن شما اجازه می‌دهد به داده‌های سلامت و تناسب اندام در دستگاه‌های iOS و Android دسترسی داشته باشد.

## پشتیبانی پلتفرم‌ها

| پلتفرم | حداقل نسخه | وضعیت | توضیحات |
|--------|-----------|-------|---------|
| iOS | 13.0+ | ✅ پشتیبانی کامل | نیاز به HealthKit |
| iOS | 8.0-12.x | ⚠️ محدود | HealthKit پایه موجود است اما توصیه نمی‌شود |
| iOS | < 8.0 | ❌ پشتیبانی نمی‌شود | HealthKit موجود نیست |
| Android | 14+ (API 34+) | ✅ پشتیبانی کامل | Health Connect داخلی |
| Android | 10-13 (API 29-33) | ⚠️ نیاز به اپ | Health Connect به عنوان اپ جداگانه |
| Android | < 10 (API < 29) | ❌ پشتیبانی نمی‌شود | Health Connect موجود نیست |
| macOS | همه | ❌ پشتیبانی نمی‌شود | HealthKit فقط iOS |

## راه‌اندازی iOS

### 1. اضافه کردن قابلیت HealthKit

در Xcode:
1. فایل `ios/Runner.xcworkspace` را باز کنید
2. target خود (Runner) را انتخاب کنید
3. به "Signing & Capabilities" بروید
4. روی "+ Capability" کلیک کنید
5. "HealthKit" را اضافه کنید

### 2. به‌روزرسانی Info.plist

کلیدهای زیر را به `ios/Runner/Info.plist` اضافه کنید:

```xml
<!-- Health Permission -->
<key>NSHealthShareUsageDescription</key>
<string>این برنامه برای پیگیری پیشرفت تناسب اندام شما به داده‌های سلامتی نیاز دارد</string>

<key>NSHealthUpdateUsageDescription</key>
<string>این برنامه برای ثبت فعالیت‌های شما به به‌روزرسانی داده‌های سلامتی نیاز دارد</string>
```

### 3. حداقل نسخه iOS

مطمئن شوید `ios/Podfile` حداقل iOS 13.0 دارد:

```ruby
platform :ios, '13.0'
```

یا بهتر است از iOS 14.0+ استفاده کنید:

```ruby
platform :ios, '14.0'
```

## راه‌اندازی Android

### Android 14+ (API 34+)

Health Connect در Android 14+ داخلی است. نیازی به راه‌اندازی اضافی نیست.

### Android 10-13 (API 29-33)

کاربران باید Health Connect را از Google Play Store نصب کنند:
1. Google Play Store را باز کنید
2. "Health Connect" را جستجو کنید
3. اپلیکیشن را نصب کنید
4. مجوزها را از طریق اپ Health Connect اعطا کنید

### مجوزها در AndroidManifest.xml

موارد زیر را به `android/app/src/main/AndroidManifest.xml` اضافه کنید:

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

## استفاده

### درخواست مجوز سلامتی

```dart
import 'package:permission_master/permission_master.dart';

// درخواست مجوز سلامتی
final result = await PermissionMaster.requestHealthPermission();

if (result == 'granted') {
  print('مجوز سلامتی اعطا شد');
} else if (result == 'denied') {
  print('مجوز سلامتی رد شد');
} else if (result == 'NOT_SUPPORTED') {
  print('مجوز سلامتی در این دستگاه/نسخه سیستم‌عامل پشتیبانی نمی‌شود');
} else if (result == 'REQUIRES_HEALTH_CONNECT_APP') {
  print('لطفاً اپ Health Connect را از Play Store نصب کنید');
} else if (result == 'OPEN_SETTINGS') {
  print('تنظیمات Health Connect باز شد');
}
```

## مقادیر بازگشتی

### iOS

- `granted` - کاربر مجوز سلامتی را اعطا کرد
- `denied` - کاربر مجوز سلامتی را رد کرد
- `notDetermined` - کاربر هنوز تصمیم نگرفته
- `NOT_SUPPORTED` - دستگاه از HealthKit پشتیبانی نمی‌کند (iPad بدون اپ Health، iOS < 13)

### Android

- `OPEN_SETTINGS` - تنظیمات Health Connect باز شد (Android 14+)
- `REQUIRES_HEALTH_CONNECT_APP` - کاربر باید اپ Health Connect را نصب کند (Android 10-13)
- `NOT_SUPPORTED` - نسخه Android از Health Connect پشتیبانی نمی‌کند (< Android 10)

## نکات مهم

### iOS

1. **حریم خصوصی**: HealthKit به اپ‌ها اجازه نمی‌دهد تشخیص دهند که آیا مجوز رد شده یا اعطا نشده است.

2. **دسترسی پس‌زمینه**: اگر به دسترسی پس‌زمینه نیاز دارید:
   - قابلیت Background Modes را فعال کنید
   - حالت پس‌زمینه "Health" را اضافه کنید

3. **اپ Health لازم است**: اپ Health باید روی دستگاه نصب و راه‌اندازی شده باشد.

4. **پشتیبانی iPad**: اکثر iPad‌ها اپ Health ندارند، بنابراین HealthKit `NOT_SUPPORTED` برمی‌گرداند.

### Android

1. **اپ Health Connect**: برای Android 10-13، کاربران ابتدا باید Health Connect را از Play Store نصب کنند.

2. **مجوزهای جزئی**: Health Connect از مجوزهای جزئی استفاده می‌کند. کاربران می‌توانند به برخی انواع داده دسترسی دهند و برخی را رد کنند.

3. **مدیریت تنظیمات**: پلاگین تنظیمات Health Connect را باز می‌کند که کاربران مجوزها را مدیریت می‌کنند.

## عیب‌یابی

### iOS

**مشکل**: مجوز همیشه "denied" برمی‌گرداند
- **راه‌حل**: بررسی کنید اپ Health نصب و راه‌اندازی شده باشد
- **راه‌حل**: تأیید کنید قابلیت HealthKit در Xcode اضافه شده
- **راه‌حل**: بررسی کنید Info.plist توضیحات لازم را دارد

**مشکل**: "NOT_SUPPORTED" روی iPhone
- **راه‌حل**: مطمئن شوید نسخه iOS 13.0 یا بالاتر است
- **راه‌حل**: بررسی کنید اپ Health موجود است

### Android

**مشکل**: "REQUIRES_HEALTH_CONNECT_APP" روی Android 14+
- **راه‌حل**: این نباید روی Android 14+ اتفاق بیفتد. نسخه سیستم‌عامل را بررسی کنید.

**مشکل**: Health Connect باز نمی‌شود
- **راه‌حل**: مطمئن شوید Health Connect نصب شده (Android 10-13)
- **راه‌حل**: Health Connect را به آخرین نسخه به‌روزرسانی کنید

**مشکل**: "NOT_SUPPORTED" روی Android 10+
- **راه‌حل**: تأیید کنید سازنده دستگاه از Health Connect پشتیبانی می‌کند
- **راه‌حل**: برخی ROM‌های سفارشی Android ممکن است از Health Connect پشتیبانی نکنند

## منابع اضافی

### iOS
- [مستندات Apple HealthKit](https://developer.apple.com/documentation/healthkit)

### Android
- [مستندات Health Connect](https://developer.android.com/health-and-fitness/guides/health-connect)

## تاریخچه نسخه‌ها

- **v0.1.0**: پشتیبانی اولیه مجوز سلامتی
  - پشتیبانی iOS 13.0+ با HealthKit
  - پشتیبانی Android 14+ با Health Connect داخلی
  - پشتیبانی Android 10-13 با اپ Health Connect
  - تشخیص نسخه و پیام‌های خطای مناسب
