import 'package:flutter_test/flutter_test.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_platform_interface.dart';
import 'package:permission_master/permission_master_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionMasterPlatform
    with MockPlatformInterfaceMixin
    implements PermissionMasterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Android 14');

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) {
    return Future.value(
      permissions.asMap().map(
        (key, value) => MapEntry(value, key % 2 == 0 ? 'GRANTED' : 'DENIED'),
      ),
    );
  }

  @override
  Future<String> checkPermissionStatus(String permission) {
    return Future.value(permission.contains('CAMERA') ? 'GRANTED' : 'DENIED');
  }

  @override
  Future<void> openAppSettings() {
    return Future.value();
  }

  @override
  Future<String> requestActivityRecognitionPermission() =>
      Future.value('GRANTED');

  @override
  Future<String> requestAlarmPermission() => Future.value('DENIED');

  @override
  Future<String> requestBluetoothPermission() => Future.value('GRANTED');

  @override
  Future<String> requestCalendarPermission() => Future.value('DENIED');

  @override
  Future<String> requestCameraPermission() => Future.value('GRANTED');

  @override
  Future<String> requestContactsPermission() => Future.value('DENIED');

  @override
  Future<String> requestLocationPermission() => Future.value('GRANTED');

  @override
  Future<String> requestMicrophonePermission() => Future.value('DENIED');

  @override
  Future<String> requestNearbyDevicesPermission() => Future.value('GRANTED');

  @override
  Future<String> requestNotificationPermission() => Future.value('DENIED');

  @override
  Future<String> requestPermission(String method) {
    return Future.value(method.contains('Permission') ? 'GRANTED' : 'DENIED');
  }

  @override
  Future<String> requestPhonePermission() => Future.value('GRANTED');

  @override
  Future<String> requestSensorsPermission() => Future.value('DENIED');

  @override
  Future<String> requestSmsPermission() => Future.value('GRANTED');

  @override
  Future<String> requestStoragePermission() => Future.value('DENIED');

  @override
  Future<String> requestWifiPermission() => Future.value('GRANTED');
}

void main() {
  final PermissionMasterPlatform initialPlatform =
      PermissionMasterPlatform.instance;

  test('$MethodChannelPermissionMaster is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPermissionMaster>());
  });

  group('PermissionMaster Tests', () {
    late PermissionMaster permissionMasterPlugin;
    late MockPermissionMasterPlatform fakePlatform;

    setUp(() {
      permissionMasterPlugin = PermissionMaster();
      fakePlatform = MockPermissionMasterPlatform();
      PermissionMasterPlatform.instance = fakePlatform;
    });

    test('getPlatformVersion returns mocked value', () async {
      expect(await permissionMasterPlugin.getPlatformVersion(), 'Android 14');
    });

    test('requestCameraPermission returns GRANTED', () async {
      expect(await permissionMasterPlugin.requestCameraPermission(), 'GRANTED');
    });

    test('requestLocationPermission returns GRANTED', () async {
      expect(
        await permissionMasterPlugin.requestLocationPermission(),
        'GRANTED',
      );
    });

    test('requestMicrophonePermission returns DENIED', () async {
      expect(
        await permissionMasterPlugin.requestMicrophonePermission(),
        'DENIED',
      );
    });

    test('checkPermissionStatus returns correct status', () async {
      expect(
        await permissionMasterPlugin.checkPermissionStatus(
          'android.permission.CAMERA',
        ),
        'GRANTED',
      );
      expect(
        await permissionMasterPlugin.checkPermissionStatus(
          'android.permission.RECORD_AUDIO',
        ),
        'DENIED',
      );
    });

    test('checkMultiplePermissions returns mixed statuses', () async {
      final permissions = [
        'android.permission.CAMERA',
        'android.permission.RECORD_AUDIO',
        'android.permission.ACCESS_FINE_LOCATION',
      ];
      final result = await permissionMasterPlugin.checkMultiplePermissions(
        permissions
            .map((p) => PermissionType.values.firstWhere((pt) => pt.value == p))
            .toList(),
      );
      expect(result['android.permission.CAMERA'], 'GRANTED');
      expect(result['android.permission.RECORD_AUDIO'], 'DENIED');
      expect(result['android.permission.ACCESS_FINE_LOCATION'], 'GRANTED');
    });

    test('openAppSettings completes successfully', () async {
      await expectLater(permissionMasterPlugin.openAppSettings(), completes);
    });
  });
}
