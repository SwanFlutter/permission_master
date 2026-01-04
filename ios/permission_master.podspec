#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint permission_master.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'permission_master'
  s.version          = '0.0.1'
  s.summary          = 'Permission Master is a comprehensive Flutter plugin designed to simplify permission management across iOS and Android platforms. It provides an intuitive and easy-to-use interface for requesting and checking various system permissions while ensuring a smooth user experience.'
  s.description      = <<-DESC
Permission Master is a comprehensive Flutter plugin designed to simplify permission management across iOS and Android platforms. It provides an intuitive and easy-to-use interface for requesting and checking various system permissions while ensuring a smooth user experience.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # No default usage descriptions included
  # Add only the usage descriptions you need in your app's Info.plist
  # See README.md for the complete list of available iOS permissions

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'permission_master_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
