#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint permission_master.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'permission_master'
  s.version          = '0.1.0'
  s.summary          = 'Permission Master is a Flutter plugin for managing and requesting permissions on All Platform.'
  s.description      = <<-DESC
Permission Master is a Flutter plugin for managing and requesting permissions on All Platform.
                       DESC
  s.homepage         = 'https://github.com/SwanFlutter/permission_master'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SwanFlutter' => 'your-email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'permission_master/Sources/permission_master/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'
  s.resource_bundles = {'permission_master_privacy' => ['permission_master/Sources/permission_master/PrivacyInfo.xcprivacy']}

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
