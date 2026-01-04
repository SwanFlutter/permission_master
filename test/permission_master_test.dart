import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_method_channel.dart';
import 'package:permission_master/permission_master_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionMasterPlatform
    with MockPlatformInterfaceMixin
    implements PermissionMasterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<String> checkPermissionStatus(String permission) {
    throw UnimplementedError();
  }

  @override
  Future<void> openAppSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> openCameraSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> openMicrophoneSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> openLocationSettings() {
    throw UnimplementedError();
  }

  @override
  Future<void> openNotificationSettings() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestActivityRecognitionPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestAlarmPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestBluetoothPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCalendarPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCameraPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestContactsPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNearbyDevicesPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestPermission(String method) {
    throw UnimplementedError();
  }

  @override
  Future<String> requestPhonePermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestSensorsPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestSmsPermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestStoragePermission() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestWifiPermission() {
    throw UnimplementedError();
  }

  @override
  void setContext(BuildContext context) {}

  @override
  Future<String> checkCameraPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkMicrophonePermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkPermissionStatusWindows(String permission) {
    throw UnimplementedError();
  }

  @override
  Future<void> openAppSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openCameraSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openMicrophoneSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCameraPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkEmailPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkLocationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkNotificationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkRadiosPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkVoiceActivationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openLocationSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openNotificationSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openRadiosSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<void> openSpeechSettingsWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestEmailPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestRadiosPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestVoiceActivationPermissionWindows() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkBluetoothPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkCalendarPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkCameraPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkContactsPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkLocationPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkMicrophonePermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkNotificationPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkPhotoLibraryPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkRemindersPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> checkSpeechRecognitionPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<void> openAppSettingsMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestBluetoothPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCalendarPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCameraPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestContactsPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestPhotoLibraryPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestRemindersPermissionMac() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestSpeechRecognitionPermissionMac() {
    throw UnimplementedError();
  }

  // Linux specific methods
  @override
  Future<String> requestCameraPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestStoragePermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestContactsPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCalendarPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestBluetoothPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNetworkPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestUsbPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<void> openAppSettingsLinux() {
    throw UnimplementedError();
  }
}

void main() {
  final PermissionMasterPlatform initialPlatform =
      PermissionMasterPlatform.instance;

  test('$MethodChannelPermissionMaster is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPermissionMaster>());
  });

  test('getPlatformVersion', () async {
    PermissionMaster permissionMasterPlugin = PermissionMaster();
    MockPermissionMasterPlatform fakePlatform = MockPermissionMasterPlatform();
    PermissionMasterPlatform.instance = fakePlatform;

    expect(await permissionMasterPlugin.getPlatformVersion(), '42');
  });
}
