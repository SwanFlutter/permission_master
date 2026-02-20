#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint permission_master_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'permission_master_ios'
  s.version          = '0.0.1'
  s.summary          = 'A comprehensive iOS permission management plugin for Flutter.'
  s.description      = <<-DESC
Permission Master iOS is a Flutter plugin that provides comprehensive iOS permission management
with built-in storage capabilities. Supports 13 different permission types including Camera,
Photos, Microphone, Location, Contacts, Calendar, Reminders, Notifications, Bluetooth, Motion,
Speech Recognition, Media Library, and Health data.
                       DESC
  s.homepage         = 'https://github.com/yourusername/permission_master_ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Privacy manifest for App Store compliance
  s.resource_bundles = {'permission_master_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
