# iOS Permission Setup Guide

## Quick Start: 3-Step Configuration

### Step 1: Enable Permissions in Podfile

Edit `ios/Podfile` and add the `post_install` block. **Only uncomment the permissions you need:**

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        # Uncomment only what you need:
        # 'PERMISSION_CAMERA=1',
        # 'PERMISSION_PHOTOS=1',
        # 'PERMISSION_LOCATION=1',
        # 'PERMISSION_CONTACTS=1',
        # 'PERMISSION_BLUETOOTH=1',
        # 'PERMISSION_MICROPHONE=1',
        # 'PERMISSION_SPEECH_RECOGNITION=1',
        # 'PERMISSION_NOTIFICATIONS=1',
        # 'PERMISSION_CALENDAR=1',
        # 'PERMISSION_REMINDERS=1',
        # 'PERMISSION_MOTION=1',
        # 'PERMISSION_MUSIC_LIBRARY=1',
        # 'PERMISSION_HEALTH=1',
      ]
    end
  end
end
```

### Step 2: Add Usage Descriptions to Info.plist

For each permission you enabled in Step 1, add the corresponding key to `ios/Runner/Info.plist`:

| Podfile Permission | Required Info.plist Key(s) |
|-------------------|---------------------------|
| `PERMISSION_CAMERA=1` | `NSCameraUsageDescription` |
| `PERMISSION_PHOTOS=1` | `NSPhotoLibraryUsageDescription`<br>`NSPhotoLibraryAddUsageDescription` |
| `PERMISSION_LOCATION=1` | `NSLocationWhenInUseUsageDescription`<br>(Optional: `NSLocationAlwaysAndWhenInUseUsageDescription`) |
| `PERMISSION_MICROPHONE=1` | `NSMicrophoneUsageDescription` |
| `PERMISSION_CONTACTS=1` | `NSContactsUsageDescription` |
| `PERMISSION_CALENDAR=1` | `NSCalendarsUsageDescription` |
| `PERMISSION_REMINDERS=1` | `NSRemindersUsageDescription` |
| `PERMISSION_MOTION=1` | `NSMotionUsageDescription` |
| `PERMISSION_BLUETOOTH=1` | `NSBluetoothAlwaysUsageDescription` |
| `PERMISSION_HEALTH=1` | `NSHealthShareUsageDescription`<br>`NSHealthUpdateUsageDescription` |
| `PERMISSION_SPEECH_RECOGNITION=1` | `NSSpeechRecognitionUsageDescription` |
| `PERMISSION_MUSIC_LIBRARY=1` | `NSAppleMusicUsageDescription` |
| `PERMISSION_NOTIFICATIONS=1` | No Info.plist key required |

### Step 3: Install Pods and Clean Build

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

## Common Errors and Solutions

### Error: "Missing purpose string in Info.plist"

**Symptoms:**
```
90683: Missing purpose string in Info.plist. Your app's code references one or more APIs that 
access sensitive user data. The Info.plist file should contain a NSContactsUsageDescription key...
```

**Cause:** You enabled a permission in Podfile but didn't add its usage description to Info.plist.

**Solution:**
1. Check which permission is mentioned in the error (e.g., `NSContactsUsageDescription`)
2. Either:
   - **Option A:** Add the usage description to `ios/Runner/Info.plist` if you need this permission
   - **Option B:** Comment out the permission in `ios/Podfile` if you don't need it
3. Run `cd ios && pod install && cd .. && flutter clean`

### Error: Build fails after adding permissions

**Cause:** Pods not reinstalled after Podfile changes.

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

## Example Configurations

### Example 1: Camera + Photo Library App

`ios/Podfile`:
```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  '$(inherited)',
  'PERMISSION_CAMERA=1',
  'PERMISSION_PHOTOS=1',
]
```

`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to select photos from your gallery</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos to your gallery</string>
```

### Example 2: Location Tracking App

`ios/Podfile`:
```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  '$(inherited)',
  'PERMISSION_LOCATION=1',
]
```

`ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to provide location-based services</string>
```

### Example 3: Voice Recording App

`ios/Podfile`:
```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  '$(inherited)',
  'PERMISSION_MICROPHONE=1',
]
```

`ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio</string>
```

## Important Notes

1. **Never copy all permissions** - Only enable what your app actually uses
2. **Customize usage descriptions** - Make them specific to your app's functionality
3. **Apple will reject your app if:**
   - You enable a permission in Podfile but don't add its usage description
   - Your usage description is generic or doesn't explain why you need the permission
   - You request permissions you don't actually use

4. **After any Podfile changes:**
   - Always run `pod install`
   - Always run `flutter clean`
   - Rebuild your app

## Testing Permissions

To test if permissions are configured correctly:

1. Run your app on a real iOS device or simulator
2. Try to request each permission you configured
3. Check that the permission dialog shows your custom usage description
4. Verify that denied permissions can be re-enabled in iOS Settings

## Need Help?

- See `ios/Info.plist.example` for a complete reference of all available permissions
- Check the main README.md for detailed usage examples
- Ensure your Podfile and Info.plist are in sync
