import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_platform_interface.dart';
import 'package:permission_master/permission_master_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionMasterPlatform
    with MockPlatformInterfaceMixin
    implements PermissionMasterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, String>> checkMultiplePermissions(List<String> permissions) {
    // TODO: implement checkMultiplePermissions
    throw UnimplementedError();
  }

  @override
  Future<String> checkPermissionStatus(String permission) {
    // TODO: implement checkPermissionStatus
    throw UnimplementedError();
  }

  @override
  Future<void> openAppSettings() {
    // TODO: implement openAppSettings
    throw UnimplementedError();
  }

  @override
  Future<String> requestActivityRecognitionPermission() {
    // TODO: implement requestActivityRecognitionPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestAlarmPermission() {
    // TODO: implement requestAlarmPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestBluetoothPermission() {
    // TODO: implement requestBluetoothPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestCalendarPermission() {
    // TODO: implement requestCalendarPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestCameraPermission() {
    // TODO: implement requestCameraPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestContactsPermission() {
    // TODO: implement requestContactsPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermission() {
    // TODO: implement requestLocationPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermission() {
    // TODO: implement requestMicrophonePermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestNearbyDevicesPermission() {
    // TODO: implement requestNearbyDevicesPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermission() {
    // TODO: implement requestNotificationPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestPermission(String method) {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestPhonePermission() {
    // TODO: implement requestPhonePermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestSensorsPermission() {
    // TODO: implement requestSensorsPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestSmsPermission() {
    // TODO: implement requestSmsPermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestStoragePermission() {
    // TODO: implement requestStoragePermission
    throw UnimplementedError();
  }

  @override
  Future<String> requestWifiPermission() {
    // TODO: implement requestWifiPermission
    throw UnimplementedError();
  }

  @override
  void setContext(BuildContext context) {
    // TODO: implement setContext
  }
}

void main() {
  final PermissionMasterPlatform initialPlatform = PermissionMasterPlatform.instance;

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
