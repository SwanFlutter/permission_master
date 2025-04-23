#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint permission_master.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'permission_master'
  s.version          = '0.0.1'
  s.summary          = 'A comprehensive Flutter plugin for handling permissions'
  s.description      = <<-DESC
A comprehensive Flutter plugin for handling permissions in iOS and Android with advanced features like permission tracking, automatic retry management, and smart dialogs.
                       DESC
  s.homepage         = 'https://github.com/YourUsername/permission_master'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  # Privacy descriptions
  s.info_plist = {
    'NSCameraUsageDescription' => 'This app needs camera access for taking photos and scanning.',
    'NSPhotoLibraryUsageDescription' => 'This app needs photo library access for saving and sharing media.',
    'NSLocationWhenInUseUsageDescription' => 'This app needs location access for navigation features.',
    'NSLocationAlwaysUsageDescription' => 'This app needs background location access for continuous tracking.',
    'NSLocationAlwaysAndWhenInUseUsageDescription' => 'This app needs location access for navigation and tracking features.',
    'NSContactsUsageDescription' => 'This app needs contacts access for social features.',
    'NSBluetoothAlwaysUsageDescription' => 'This app needs bluetooth access for connecting to nearby devices.',
    'NSBluetoothPeripheralUsageDescription' => 'This app needs bluetooth access for connecting to peripherals.',
    'NSMicrophoneUsageDescription' => 'This app needs microphone access for voice features.',
    'NSCalendarsUsageDescription' => 'This app needs calendar access for event management.',
    'NSMotionUsageDescription' => 'This app needs motion and fitness access for activity tracking.',
    'NSSpeechRecognitionUsageDescription' => 'This app needs speech recognition for voice commands.',
    'NSAppleMusicUsageDescription' => 'This app needs music library access for media features.'
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'permission_master_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
