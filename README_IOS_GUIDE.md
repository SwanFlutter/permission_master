# Permission Master

A Flutter plugin for managing iOS permissions with data storage capabilities.

## Features

✅ Full iOS permission management  
✅ Support for 13 different permission types  
✅ Data storage using UserDefaults  
✅ Compatible with App Store standards  
✅ Supports iOS 14.0 and above  
✅ Smart permission request count management  

---

## Supported Permissions

| Permission       | Description                    |
|------------------|--------------------------------|
| 📷 Camera        | Access to the camera           |
| 🖼️ Photos        | Access to the photo library    |
| 🎤 Microphone    | Access to the microphone       |
| 📍 Location      | Access to location services    |
| 👥 Contacts      | Access to contacts             |
| 📅 Calendar      | Access to calendar events      |
| ⏰ Reminders     | Access to reminders            |
| 🔔 Notifications | Access to notifications        |
| 📶 Bluetooth     | Access to Bluetooth            |
| 🏃 Motion        | Access to motion & fitness     |
| 🗣️ Speech        | Access to speech recognition   |
| 🎵 Music         | Access to the media library    |
| ❤️ Health        | Access to health data          |

---


### 3. iOS Setup

#### a) Add permission descriptions to `Info.plist`

Open `ios/Runner/Info.plist` and add the required permission descriptions:

```xml
<dict>
    <!-- Camera -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to take photos</string>

    <!-- Photo Library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access to select images</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>This app needs photo library access to save images</string>

    <!-- Microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access to record audio</string>

    <!-- Location -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to display your position</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to track your position</string>

    <!-- Contacts -->
    <key>NSContactsUsageDescription</key>
    <string>This app needs contacts access to display your contacts</string>

    <!-- Calendar -->
    <key>NSCalendarsUsageDescription</key>
    <string>This app needs calendar access to manage events</string>

    <!-- Reminders -->
    <key>NSRemindersUsageDescription</key>
    <string>This app needs reminders access to manage your reminders</string>

    <!-- Bluetooth -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth access to connect to devices</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth access to connect to devices</string>

    <!-- Motion -->
    <key>NSMotionUsageDescription</key>
    <string>This app needs motion access to track physical activity</string>

    <!-- Speech Recognition -->
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app needs speech recognition access for voice commands</string>

    <!-- Media Library -->
    <key>NSAppleMusicUsageDescription</key>
    <string>This app needs media library access to play music</string>

    <!-- Health -->
    <key>NSHealthShareUsageDescription</key>
    <string>This app needs health data access to read health information</string>
    <key>NSHealthUpdateUsageDescription</key>
    <string>This app needs health data access to update health information</string>
</dict>
```

#### b) Create `Podfile`

If `ios/Podfile` does not exist, create it:

```ruby
# ios/Podfile
platform :ios, '14.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

Or simply run:

```bash
flutter create --platforms=ios .
```

### 4. Run Pod Install

```bash
cd ios
pod install
cd ..
```

---

## Permission Statuses

```dart
enum PermissionStatus {
  granted,        // Permission granted
  denied,         // Permission denied
  restricted,     // Restricted (parental controls, MDM, etc.)
  limited,        // Limited access (e.g. selected photos on iOS 14+)
  notDetermined,  // Not requested yet
  openSettings,   // Needs to open Settings to change
  unsupported,    // Not supported on this device
  error           // An error occurred
}
```

---

## Usage

### 📷 Camera Permission

```dart
Future<void> requestCameraAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses AVCaptureDevice under the hood
  final status = await permissionMaster.requestCameraPermission();

  if (status == PermissionStatus.granted) {
    // Camera access granted - can use AVCaptureSession
    print('Camera permission granted - can use AVCaptureSession');
  } else if (status == PermissionStatus.denied) {
    print('Camera access denied. Enable in Settings > Privacy & Security > Camera');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Camera access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting camera permission');
  }
}
```

---

### 🖼️ Photos Permission

```dart
Future<void> requestPhotosAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses PHPhotoLibrary under the hood
  final status = await permissionMaster.requestPhotosPermission();

  if (status == PermissionStatus.granted) {
    // Full photo library access granted
    print('Photos permission granted - full PHPhotoLibrary access');
  } else if (status == PermissionStatus.limited) {
    // iOS 14+ only: user selected specific photos
    print('Photos permission limited - selected photos only (iOS 14+)');
  } else if (status == PermissionStatus.denied) {
    print('Photos access denied. Enable in Settings > Privacy & Security > Photos');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Photos access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting photos permission');
  }
}
```

---

### 🎤 Microphone Permission

```dart
Future<void> requestMicrophoneAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses AVAudioSession under the hood
  final status = await permissionMaster.requestMicrophonePermission();

  if (status == PermissionStatus.granted) {
    // Microphone access granted - can use AVAudioSession
    print('Microphone permission granted - can use AVAudioSession');
  } else if (status == PermissionStatus.denied) {
    print('Microphone access denied. Enable in Settings > Privacy & Security > Microphone');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Microphone access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting microphone permission');
  }
}
```

---

### 📍 Location Permission

```dart
Future<void> requestLocationAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses CLLocationManager under the hood
  final status = await permissionMaster.requestLocationPermission();

  if (status == PermissionStatus.granted) {
    // Location access granted - can use CLLocationManager
    print('Location permission granted - can use CLLocationManager');
  } else if (status == PermissionStatus.denied) {
    print('Location access denied. Enable in Settings > Privacy & Security > Location Services');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Location access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting location permission');
  }
}
```

---

### 👥 Contacts Permission

```dart
Future<void> requestContactsAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses CNContactStore under the hood
  final status = await permissionMaster.requestContactsPermission();

  if (status == PermissionStatus.granted) {
    // Contacts access granted - can use CNContactStore
    print('Contacts permission granted - can use CNContactStore');
  } else if (status == PermissionStatus.denied) {
    print('Contacts access denied. Enable in Settings > Privacy & Security > Contacts');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Contacts access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting contacts permission');
  }
}
```

---

### 📅 Calendar Permission

```dart
Future<void> requestCalendarAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses EKEventStore under the hood
  final status = await permissionMaster.requestCalendarPermission();

  if (status == PermissionStatus.granted) {
    // Calendar access granted - can use EKEventStore
    print('Calendar permission granted - can use EKEventStore');
  } else if (status == PermissionStatus.denied) {
    print('Calendar access denied. Enable in Settings > Privacy & Security > Calendars');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Calendar access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting calendar permission');
  }
}
```

---

### ⏰ Reminders Permission

```dart
Future<void> requestRemindersAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses EKEventStore (reminders entity) under the hood
  final status = await permissionMaster.requestRemindersPermission();

  if (status == PermissionStatus.granted) {
    // Reminders access granted - can use EKEventStore with reminders
    print('Reminders permission granted - can use EKEventStore for reminders');
  } else if (status == PermissionStatus.denied) {
    print('Reminders access denied. Enable in Settings > Privacy & Security > Reminders');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Reminders access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting reminders permission');
  }
}
```

---

### 🔔 Notifications Permission

```dart
Future<void> requestNotificationAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses UNUserNotificationCenter under the hood
  final status = await permissionMaster.requestNotificationPermission();

  if (status == PermissionStatus.granted) {
    // Notifications granted - can use UNUserNotificationCenter
    print('Notification permission granted - can use UNUserNotificationCenter');
  } else if (status == PermissionStatus.denied) {
    print('Notifications denied. Enable in Settings > Notifications > [App Name]');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting notification permission');
  }
}
```

---

### 📶 Bluetooth Permission

```dart
Future<void> requestBluetoothAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses CBCentralManager under the hood
  final status = await permissionMaster.requestBluetoothPermission();

  if (status == PermissionStatus.granted) {
    // Bluetooth access granted - can use CBCentralManager
    print('Bluetooth permission granted - can use CBCentralManager');
  } else if (status == PermissionStatus.denied) {
    print('Bluetooth access denied. Enable in Settings > Privacy & Security > Bluetooth');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Bluetooth access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting Bluetooth permission');
  }
}
```

---

### 🏃 Motion & Fitness Permission

```dart
Future<void> requestMotionAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses CMMotionActivityManager under the hood
  final status = await permissionMaster.requestMotionPermission();

  if (status == PermissionStatus.granted) {
    // Motion access granted - can use CMMotionActivityManager
    print('Motion permission granted - can use CMMotionActivityManager');
  } else if (status == PermissionStatus.denied) {
    print('Motion access denied. Enable in Settings > Privacy & Security > Motion & Fitness');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Motion access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting motion permission');
  }
}
```

---

### 🗣️ Speech Recognition Permission

```dart
Future<void> requestSpeechAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses SFSpeechRecognizer under the hood
  final status = await permissionMaster.requestSpeechPermission();

  if (status == PermissionStatus.granted) {
    // Speech recognition granted - can use SFSpeechRecognizer
    print('Speech recognition granted - can use SFSpeechRecognizer');
  } else if (status == PermissionStatus.denied) {
    print('Speech recognition denied. Enable in Settings > Privacy & Security > Speech Recognition');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Speech recognition restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting speech recognition permission');
  }
}
```

---

### 🎵 Media Library (Music) Permission

```dart
Future<void> requestMusicAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses MPMediaLibrary under the hood
  final status = await permissionMaster.requestMusicPermission();

  if (status == PermissionStatus.granted) {
    // Media library access granted - can use MPMediaLibrary
    print('Media library permission granted - can use MPMediaLibrary');
  } else if (status == PermissionStatus.denied) {
    print('Media library access denied. Enable in Settings > Privacy & Security > Media & Apple Music');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Media library access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting media library permission');
  }
}
```

---

### ❤️ Health Permission

```dart
Future<void> requestHealthAccessiOS() async {
  final permissionMaster = PermissionMaster();

  // iOS uses HKHealthStore under the hood
  final status = await permissionMaster.requestHealthPermission();

  if (status == PermissionStatus.granted) {
    // Health access granted - can use HKHealthStore
    print('Health permission granted - can use HKHealthStore');
  } else if (status == PermissionStatus.denied) {
    print('Health access denied. Enable in Settings > Privacy & Security > Health');
  } else if (status == PermissionStatus.restricted) {
    // Parental controls or MDM policy preventing access
    print('Health access restricted by device policy or parental controls');
  } else if (status == PermissionStatus.openSettings) {
    // User previously denied - must go to Settings manually
    await permissionMaster.openAppSettings();
  } else if (status == PermissionStatus.error) {
    print('An error occurred while requesting health permission');
  }
}
```

---

### 🔍 Check Permission Status (Without Requesting)

```dart
Future<void> checkPermissionStatusiOS() async {
  final permissionMaster = PermissionMaster();

  // Check status without triggering a system dialog
  // Works with any PermissionType value
  final status = await permissionMaster.checkPermissionStatus(
    PermissionType.camera,
  );

  if (status == PermissionStatus.granted) {
    // Already granted - proceed directly with the feature
    print('Permission already granted - no need to request');
  } else if (status == PermissionStatus.notDetermined) {
    // Not yet asked - safe to call the request method
    print('Permission not requested yet - will show system dialog on request');
  } else if (status == PermissionStatus.denied) {
    // Previously denied - must guide user to iOS Settings
    print('Permission previously denied - guide user to iOS Settings');
  } else if (status == PermissionStatus.restricted) {
    // Cannot be changed by user (parental controls / MDM)
    print('Permission restricted - cannot be changed by the user');
  } else if (status == PermissionStatus.limited) {
    // Partial access only (e.g. Photos on iOS 14+)
    print('Permission limited - partial access only');
  } else if (status == PermissionStatus.unsupported) {
    // This permission is not available on the current device
    print('Permission not supported on this device');
  } else if (status == PermissionStatus.error) {
    print('An error occurred while checking permission status');
  }
}
```

---

### ⚙️ Open App Settings

```dart
Future<void> openAppSettingsiOS() async {
  final permissionMaster = PermissionMaster();

  // Navigates user directly to this app's page in iOS Settings
  final opened = await permissionMaster.openAppSettings();

  if (opened) {
    // iOS Settings app opened successfully
    print('iOS Settings opened - user can now change permissions manually');
  } else {
    // Rare edge case - Settings URL scheme unavailable
    print('Failed to open iOS Settings');
  }
}
```

---

### 💾 Storage (UserDefaults)

```dart
Future<void> useStorageiOS() async {
  final permissionMaster = PermissionMaster();
  final storage = permissionMaster.storage;

  // ✍️ Write different data types
  await storage.write('username', 'Ali');
  await storage.write('age', 25);
  await storage.write('isLoggedIn', true);
  await storage.write('score', 95.5);
  await storage.write('settings', {
    'theme': 'dark',
    'language': 'en',
    'notifications': true,
  });

  // 📖 Read data with default fallback values
  final username    = await storage.read('username', 'Guest');
  final age         = await storage.read('age', 0);
  final isLoggedIn  = await storage.read('isLoggedIn', false);
  final score       = await storage.read('score', 0.0);
  final settings    = await storage.read('settings', <String, dynamic>{});

  print('Username: $username');   // Ali
  print('Age: $age');             // 25
  print('Logged in: $isLoggedIn');// true
  print('Score: $score');         // 95.5
  print('Settings: $settings');   // {theme: dark, language: en, notifications: true}

  // ✅ Check if a key exists
  final hasUsername = await storage.contains('username');
  if (hasUsername) {
    print('Username is stored in UserDefaults');
  }

  // 🗑️ Remove a specific key
  await storage.remove('username');

  // 🧹 Clear all stored data
  await storage.clear();
}
```

---

### 🎯 Complete Permission Flow (Recommended Pattern)

```dart
Future<void> completePermissionFlowiOS(BuildContext context) async {
  final plugin = PermissionMaster();

  // Step 1: Check current status without showing a dialog
  final currentStatus = await plugin.checkPermissionStatus(PermissionType.camera);

  if (currentStatus == PermissionStatus.granted) {
    // Already granted - go straight to the feature
    _openCamera();
    return;
  }

  if (currentStatus == PermissionStatus.restricted) {
    // Cannot be changed - inform the user and stop
    _showRestrictedDialog(context);
    return;
  }

  // Step 2: Request the permission (shows system dialog on first attempt)
  final status = await plugin.requestCameraPermission();

  switch (status) {
    case PermissionStatus.granted:
      // Granted - proceed with the feature
      _openCamera();
      break;

    case PermissionStatus.limited:
      // Only for Photos: partial access granted
      _openCamera();
      break;

    case PermissionStatus.denied:
    case PermissionStatus.openSettings:
      // Denied - guide user to iOS Settings
      final shouldOpen = await _showGoToSettingsDialog(context);
      if (shouldOpen == true) {
        await plugin.openAppSettings();
      }
      break;

    case PermissionStatus.restricted:
      _showRestrictedDialog(context);
      break;

    case PermissionStatus.error:
      print('Unexpected error during permission request');
      break;

    default:
      break;
  }
}

void _openCamera() {
  print('Opening camera...');
}

void _showRestrictedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Access Restricted'),
      content: const Text(
        'Camera access is restricted on this device '
        'due to parental controls or a device policy.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<bool?> _showGoToSettingsDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Camera Permission Required'),
      content: const Text(
        'Camera access was denied. '
        'Please enable it in Settings > Privacy & Security > Camera.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

### 🗂️ UserPreferences Class (Practical Storage Example)

```dart
class UserPreferences {
  final _storage = PermissionMaster().storage;

  // Save user preferences
  Future<void> savePreferences({
    required String theme,
    required String language,
    required bool notifications,
  }) async {
    await _storage.write('user_theme', theme);
    await _storage.write('user_language', language);
    await _storage.write('user_notifications', notifications);
  }

  // Load user preferences with defaults
  Future<Map<String, dynamic>> loadPreferences() async {
    final theme         = await _storage.read('user_theme', 'light');
    final language      = await _storage.read('user_language', 'en');
    final notifications = await _storage.read('user_notifications', true);

    return {
      'theme': theme,
      'language': language,
      'notifications': notifications,
    };
  }

  // Check if preferences have been saved before
  Future<bool> hasPreferences() async {
    return await _storage.contains('user_theme');
  }

  // Reset all preferences to defaults
  Future<void> resetPreferences() async {
    await _storage.remove('user_theme');
    await _storage.remove('user_language');
    await _storage.remove('user_notifications');
  }
}

// Usage
Future<void> preferencesExample() async {
  final prefs = UserPreferences();

  // Save
  await prefs.savePreferences(
    theme: 'dark',
    language: 'en',
    notifications: true,
  );

  // Load
  final settings = await prefs.loadPreferences();
  print(settings); // {theme: dark, language: en, notifications: true}

  // Check
  final exists = await prefs.hasPreferences();
  print('Has saved preferences: $exists'); // true

  // Reset
  await prefs.resetPreferences();
}
```

---

## App Store Best Practices

### ✅ Request at the Right Time

```dart
// ❌ Bad: Requesting at app startup
@override
void initState() {
  super.initState();
  _plugin.requestCameraPermission(); // Never do this
}

// ✅ Good: Request only when the user triggers the feature
void _onCameraButtonTapped() async {
  final status = await _plugin.requestCameraPermission();
  if (status == PermissionStatus.granted) {
    _openCamera();
  }
}
```

### ✅ Always Handle All Status Cases

```dart
final status = await plugin.requestCameraPermission();

switch (status) {
  case PermissionStatus.granted:
    _openCamera();
    break;
  case PermissionStatus.limited:
    _openCamera(); // Handle limited access if needed
    break;
  case PermissionStatus.denied:
  case PermissionStatus.openSettings:
    _showSettingsDialog();
    break;
  case PermissionStatus.restricted:
    _showRestrictedMessage();
    break;
  case PermissionStatus.error:
    _showErrorMessage();
    break;
  default:
    break;
}
```

### ✅ Privacy Manifest

The `ios/Resources/PrivacyInfo.xcprivacy` file is included to comply with Apple's privacy standards.

---

## Common Issues

### "Permission denied" error

Make sure the permission description key is added to `Info.plist`.

### "Module not found" error

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Permission dialog not showing

- Verify the `Info.plist` description keys are correct
- Fully close and reopen the app (not just hot reload)
- On Simulator: reset permissions via **Device > Privacy & Security Reset**

---

## Requirements

- Flutter: `>=3.3.0`
- iOS: `>=12.0`
- Dart: `^3.10.8`