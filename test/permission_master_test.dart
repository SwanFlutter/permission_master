import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_platform_interface.dart';
import 'package:permission_master/permission_master_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Default status returned by every mock check/request method.
const String kMockPermissionStatus = 'granted';

class MockPermissionMasterPlatform
    with MockPlatformInterfaceMixin
    implements PermissionMasterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  // ------------- Check methods (macOS / Windows / generic) -------------

  @override
  Future<String> checkBluetoothPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkCalendarPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkCameraPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkCameraPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkContactsPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkEmailPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkLocationPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkLocationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkMicrophonePermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkMicrophonePermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkNotificationPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkNotificationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkPermissionStatus(String permission) =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkPermissionStatusWindows(String permission) =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkPhotoLibraryPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkRadiosPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkRemindersPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkSpeechRecognitionPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> checkVoiceActivationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) async {
    return {
      for (final permission in permissions) permission: kMockPermissionStatus,
    };
  }

  // ------------- Request methods (mobile / desktop) -------------

  @override
  Future<String> requestActivityRecognitionPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestAlarmPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestBluetoothPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestBluetoothPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestBluetoothPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCalendarPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCalendarPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCalendarPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCameraPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCameraPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCameraPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestCameraPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestContactsPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestContactsPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestContactsPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestEmailPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestHealthPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestLocationPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestLocationPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestLocationPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestLocationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestMicrophonePermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestMicrophonePermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestMicrophonePermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestMicrophonePermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNearbyDevicesPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNetworkPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNotificationPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNotificationPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNotificationPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestNotificationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestPermission(String method) =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestPhonePermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestPhotoLibraryPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestRadiosPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestRemindersPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestSensorsPermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestSmsPermission() => Future.value(kMockPermissionStatus);

  @override
  Future<String> requestSpeechRecognitionPermissionMac() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestStoragePermission() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestStoragePermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestUsbPermissionLinux() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestVoiceActivationPermissionWindows() =>
      Future.value(kMockPermissionStatus);

  @override
  Future<String> requestWifiPermission() => Future.value(kMockPermissionStatus);

  // ------------- Settings / misc -------------

  @override
  Future<void> openAppSettings() => Future.value();

  @override
  Future<void> openAppSettingsLinux() => Future.value();

  @override
  Future<void> openAppSettingsMac() => Future.value();

  @override
  Future<void> openAppSettingsWindows() => Future.value();

  @override
  Future<void> openCameraSettings() => Future.value();

  @override
  Future<void> openCameraSettingsWindows() => Future.value();

  @override
  Future<void> openLocationSettings() => Future.value();

  @override
  Future<void> openLocationSettingsWindows() => Future.value();

  @override
  Future<void> openMicrophoneSettings() => Future.value();

  @override
  Future<void> openMicrophoneSettingsWindows() => Future.value();

  @override
  Future<void> openNotificationSettings() => Future.value();

  @override
  Future<void> openNotificationSettingsWindows() => Future.value();

  @override
  Future<void> openRadiosSettingsWindows() => Future.value();

  @override
  Future<void> openSpeechSettingsWindows() => Future.value();

  @override
  void setContext(BuildContext context) {
    // No context needed in the mock.
  }
}

void main() {
  final PermissionMasterPlatform initialPlatform =
      PermissionMasterPlatform.instance;

  setUp(() {
    // Ensure every test starts from the real platform implementation.
    PermissionMasterPlatform.instance = initialPlatform;
  });

  test('$MethodChannelPermissionMaster is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPermissionMaster>());
  });

  test('getPlatformVersion', () async {
    final PermissionMaster permissionMasterPlugin = PermissionMaster();
    final MockPermissionMasterPlatform fakePlatform =
        MockPermissionMasterPlatform();
    PermissionMasterPlatform.instance = fakePlatform;

    expect(await permissionMasterPlugin.getPlatformVersion(), '42');
  });

  test(
    'checkMultiplePermissions returns granted for every permission',
    () async {
      final MockPermissionMasterPlatform fakePlatform =
          MockPermissionMasterPlatform();
      PermissionMasterPlatform.instance = fakePlatform;

      final result = await fakePlatform.checkMultiplePermissions([
        'camera',
        'microphone',
      ]);
      expect(result, {'camera': 'granted', 'microphone': 'granted'});
    },
  );

  test('requestPermission returns granted', () async {
    final MockPermissionMasterPlatform fakePlatform =
        MockPermissionMasterPlatform();
    PermissionMasterPlatform.instance = fakePlatform;

    expect(await fakePlatform.requestPermission('camera'), 'granted');
  });
}
