# iOS Testing Guide for Permission Master Example

این راهنما برای تست کردن پلاگین Permission Master روی iOS در macOS است.

## پیش‌نیازها (Prerequisites)

قبل از شروع، مطمئن شوید که موارد زیر را نصب کرده‌اید:

- ✅ **Xcode 14.0+** (از App Store)
- ✅ **CocoaPods** (برای مدیریت وابستگی‌های iOS)
- ✅ **Flutter SDK** (نسخه stable)
- ✅ **macOS 12.0+**

### نصب CocoaPods

اگر CocoaPods نصب نیست:

```bash
sudo gem install cocoapods
```

بررسی نصب:

```bash
pod --version
```

## مراحل راه‌اندازی برای تست iOS

### مرحله 1: آماده‌سازی پروژه

```bash
# رفتن به پوشه example
cd example

# دریافت وابستگی‌های Flutter
flutter pub get

# رفتن به پوشه iOS
cd ios

# ⚠️ مهم: کپی کردن Podfile.example به Podfile
cp Podfile.example Podfile
```

**⚠️ چرا این کار ضروری است؟**

در پروژه‌های معمولی Flutter، فایل `Podfile` خودکار ساخته می‌شود. اما در این پلاگین:

1. **فایل `Podfile` عمداً وجود ندارد** - برای جلوگیری از رد شدن در App Store
2. **شما باید خودتان permissions را انتخاب کنید** - فقط مجوزهایی که واقعاً نیاز دارید
3. **پلاگین بدون Podfile کار نمی‌کند** - چون کد Swift از Conditional Compilation استفاده می‌کند

بنابراین، باید `Podfile.example` را به `Podfile` کپی کنید و سپس مجوزهای مورد نیاز را فعال کنید.

### مرحله 2: پیکربندی Permissions

**⚠️ مهم:** شما باید مجوزهایی که می‌خواهید تست کنید را فعال کنید.

#### 2.1. ویرایش Podfile

حالا فایل `ios/Podfile` را باز کنید و مجوزهای مورد نیاز را uncomment کنید:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',

        # برای تست، این مجوزها را uncomment کنید:
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_LOCATION=1',
        'PERMISSION_CONTACTS=1',
        'PERMISSION_MICROPHONE=1',
        'PERMISSION_NOTIFICATIONS=1',
        'PERMISSION_CALENDAR=1',
        'PERMISSION_BLUETOOTH=1',
        
        # در صورت نیاز:
        # 'PERMISSION_MOTION=1',
        # 'PERMISSION_SPEECH_RECOGNITION=1',
        # 'PERMISSION_REMINDERS=1',
        # 'PERMISSION_MUSIC_LIBRARY=1',
        # 'PERMISSION_HEALTH=1',
      ]
    end
  end
end
```

#### 2.2. افزودن Usage Descriptions به Info.plist

فایل `ios/Runner/Info.plist` را باز کنید و قبل از تگ `</dict>` آخر، این کدها را اضافه کنید:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>این اپلیکیشن برای گرفتن عکس و ویدیو به دوربین نیاز دارد</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>این اپلیکیشن برای انتخاب تصاویر به گالری عکس نیاز دارد</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>این اپلیکیشن برای ذخیره عکس‌ها به گالری نیاز دارد</string>

<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>این اپلیکیشن برای ارائه خدمات مبتنی بر موقعیت به دسترسی موقعیت مکانی نیاز دارد</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>این اپلیکیشن برای بهترین تجربه کاربری به موقعیت مکانی شما نیاز دارد</string>

<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>این اپلیکیشن برای ضبط صدا به میکروفون نیاز دارد</string>

<!-- Contacts Permission -->
<key>NSContactsUsageDescription</key>
<string>این اپلیکیشن برای دسترسی به مخاطبین شما نیاز دارد</string>

<!-- Bluetooth Permission -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>این اپلیکیشن برای اتصال به دستگاه‌های بلوتوث نیاز دارد</string>

<!-- Calendar Permission -->
<key>NSCalendarsUsageDescription</key>
<string>این اپلیکیشن برای دسترسی به تقویم شما نیاز دارد</string>

<!-- Notifications Permission -->
<!-- نیازی به usage description ندارد -->

<!-- Motion/Sensors Permission (اختیاری) -->
<key>NSMotionUsageDescription</key>
<string>این اپلیکیشن برای ردیابی فعالیت به سنسورهای حرکتی نیاز دارد</string>

<!-- Speech Recognition Permission (اختیاری) -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>این اپلیکیشن برای تبدیل گفتار به متن نیاز دارد</string>

<!-- Reminders Permission (اختیاری) -->
<key>NSRemindersUsageDescription</key>
<string>این اپلیکیشن برای دسترسی به یادآورها نیاز دارد</string>

<!-- Health Permission (اختیاری) -->
<key>NSHealthShareUsageDescription</key>
<string>این اپلیکیشن برای خواندن داده‌های سلامتی شما نیاز دارد</string>
<key>NSHealthUpdateUsageDescription</key>
<string>این اپلیکیشن برای به‌روزرسانی داده‌های سلامتی شما نیاز دارد</string>

<!-- Music Library Permission (اختیاری) -->
<key>NSAppleMusicUsageDescription</key>
<string>این اپلیکیشن برای دسترسی به کتابخانه موسیقی شما نیاز دارد</string>
```

#### 2.3. نصب Pods

پس از ویرایش Podfile، وابستگی‌های iOS را نصب کنید:

```bash
# اگر در پوشه example هستید:
cd ios
pod install
cd ..

# یا اگر در پوشه example/ios هستید:
pod install
```

### مرحله 3: اجرای برنامه روی iOS

#### روش 1: استفاده از Flutter CLI

```bash
# از پوشه example
flutter run -d ios
```

یا برای انتخاب دستگاه خاص:

```bash
# لیست دستگاه‌های موجود
flutter devices

# اجرا روی iPhone Simulator
flutter run -d "iPhone 15 Pro"

# اجرا روی دستگاه واقعی
flutter run -d "Your iPhone Name"
```

#### روش 2: استفاده از Xcode

1. فایل `ios/Runner.xcworkspace` را در Xcode باز کنید (نه `.xcodeproj`)
2. یک Simulator یا دستگاه واقعی انتخاب کنید
3. دکمه Run (▶️) را بزنید

### مرحله 4: تست مجوزها

برنامه را اجرا کنید و هر مجوز را تست کنید:

1. **Camera**: دکمه "Request" کنار Camera را بزنید
2. **Location**: دکمه "Request" کنار Location را بزنید
3. **Storage/Photos**: دکمه "Request" کنار Storage را بزنید
4. **Microphone**: دکمه "Request" کنار Microphone را بزنید
5. **Contacts**: دکمه "Request" کنار Contacts را بزنید
6. **Bluetooth**: دکمه "Request" کنار Bluetooth را بزنید
7. **Notifications**: دکمه "Request" کنار Notifications را بزنید
8. **Calendar**: دکمه "Request" کنار Calendar را بزنید

#### تست Multiple Permissions

در بالای صفحه:
- **Check Multiple**: وضعیت چند مجوز را همزمان بررسی می‌کند
- **Request Multiple**: چند مجوز را به صورت ترتیبی درخواست می‌کند

## رفع مشکلات رایج (Troubleshooting)

### خطا: "Missing purpose string in Info.plist"

**علت:** یک permission در Podfile فعال شده اما usage description آن در Info.plist نیست.

**راه حل:**
1. بررسی کنید کدام permission در Podfile uncomment شده
2. usage description مربوطه را به Info.plist اضافه کنید
3. `pod install` را مجدد اجرا کنید

### خطا: "No such module 'permission_master'"

**راه حل:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### خطا: Build Failed در Xcode

**راه حل:**
1. Product → Clean Build Folder (Shift+Cmd+K)
2. پوشه `ios/Pods` را حذف کنید
3. `pod install` را مجدد اجرا کنید
4. دوباره build کنید

### مجوز درخواست نمی‌شود

**بررسی کنید:**
1. آیا permission در Podfile فعال شده؟
2. آیا usage description در Info.plist اضافه شده؟
3. آیا `pod install` اجرا شده؟
4. آیا برنامه را rebuild کرده‌اید؟

### تست روی دستگاه واقعی

برای تست روی iPhone واقعی:

1. **تنظیمات Signing در Xcode:**
   - فایل `Runner.xcworkspace` را باز کنید
   - Runner → Signing & Capabilities
   - Team خود را انتخاب کنید
   - Bundle Identifier منحصر به فرد بگذارید

2. **اتصال دستگاه:**
   - iPhone را به Mac وصل کنید
   - در iPhone: Settings → Privacy & Security → Developer Mode را فعال کنید
   - به دستگاه اعتماد کنید (Trust This Computer)

3. **اجرا:**
   ```bash
   flutter run -d "نام iPhone شما"
   ```

## بررسی لاگ‌ها (Debugging)

### مشاهده لاگ‌های iOS

```bash
# لاگ‌های Flutter
flutter logs

# لاگ‌های کامل iOS در Xcode
# View → Debug Area → Activate Console (Cmd+Shift+Y)
```

### بررسی وضعیت Permissions در Settings

پس از درخواست مجوزها:
1. Settings → Privacy & Security
2. هر مجوز را بررسی کنید (Camera, Location, Photos, etc.)
3. مطمئن شوید برنامه شما در لیست است

## چک‌لیست تست کامل

- [ ] CocoaPods نصب شده
- [ ] `flutter pub get` اجرا شده
- [ ] `pod install` اجرا شده
- [ ] Permissions در Podfile فعال شده‌اند
- [ ] Usage descriptions در Info.plist اضافه شده‌اند
- [ ] برنامه بدون خطا build می‌شود
- [ ] Camera permission کار می‌کند
- [ ] Location permission کار می‌کند
- [ ] Photos permission کار می‌کند
- [ ] Microphone permission کار می‌کند
- [ ] Contacts permission کار می‌کند
- [ ] Bluetooth permission کار می‌کند
- [ ] Notifications permission کار می‌کند
- [ ] Calendar permission کار می‌کند
- [ ] دکمه "Open Settings" کار می‌کند
- [ ] Multiple permissions به درستی درخواست می‌شوند

## نکات مهم

1. **همیشه از `.xcworkspace` استفاده کنید، نه `.xcodeproj`**
2. **پس از تغییر Podfile، حتماً `pod install` اجرا کنید**
3. **فقط مجوزهایی که واقعاً نیاز دارید را فعال کنید**
4. **هر permission فعال شده باید usage description داشته باشد**
5. **برای تست کامل، روی دستگاه واقعی تست کنید**

## منابع بیشتر

- [راهنمای کامل iOS در README اصلی](../../README.md#ios-configuration)
- [خلاصه رفع مشکلات iOS](../../IOS_FIX_SUMMARY.md)
- [مستندات Apple - Requesting Authorization](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/requesting_access_to_protected_resources)

## سوالات متداول

**Q: چرا باید هر permission را دستی فعال کنم؟**  
A: برای جلوگیری از رد شدن اپلیکیشن در App Store. Apple اپلیکیشن‌هایی که framework های غیرضروری import می‌کنند را رد می‌کند.

**Q: آیا می‌توانم همه permissions را فعال کنم؟**  
A: بله، اما فقط برای تست. در production فقط مجوزهای مورد نیاز را فعال کنید.

**Q: چرا برنامه در Simulator کار می‌کند اما روی دستگاه واقعی خیر؟**  
A: احتمالاً مشکل Signing است. Team و Bundle Identifier را در Xcode بررسی کنید.

---

**موفق باشید! 🚀**

اگر مشکلی پیش آمد، issue در GitHub باز کنید یا به مستندات اصلی مراجعه کنید.
