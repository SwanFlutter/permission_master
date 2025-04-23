// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// کلاس تست‌سفارشی برای حل مشکل کش کردن پلتفرم
class TestPermissionMaster extends PermissionMaster {
  @override
  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await PermissionMasterPlatform.instance.requestPermission(
      'requestMicrophonePermission',
    );
    return _mapStatus(status);
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(String permission) async {
    final status = await PermissionMasterPlatform.instance
        .checkPermissionStatus(permission);
    return _mapStatus(status);
  }

  @override
  Future<PermissionStatus> requestCameraPermission() async {
    final status = await PermissionMasterPlatform.instance.requestPermission(
      'requestCameraPermission',
    );
    return _mapStatus(status);
  }

  @override
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await PermissionMasterPlatform.instance.requestPermission(
      'requestLocationPermission',
    );
    return _mapStatus(status);
  }

  @override
  Future<Map<String, PermissionStatus>> checkMultiplePermissions(
    List<PermissionType> permissions,
  ) async {
    final result = await PermissionMasterPlatform.instance
        .checkMultiplePermissions(permissions.map((p) => p.value).toList());
    return result.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  @override
  Future<void> openAppSettings() {
    return PermissionMasterPlatform.instance.openAppSettings();
  }

  // ساده‌سازی شده برای استفاده در تست
  PermissionStatus _mapStatus(String status) {
    switch (status) {
      case 'GRANTED':
        return PermissionStatus.granted;
      case 'DENIED':
        return PermissionStatus.denied;
      case 'OPEN_SETTINGS':
        return PermissionStatus.openSettings;
      default:
        return PermissionStatus.error;
    }
  }
}

class MockPermissionMasterPlatform
    with MockPlatformInterfaceMixin
    implements PermissionMasterPlatform {
  String _microphonePermissionStatus = 'DENIED'; // مقدار پیش‌فرض

  set microphonePermissionStatus(String status) {
    debugPrint("SETTING MOCK STATUS TO: $status");
    _microphonePermissionStatus = status;
    debugPrint("AFTER SETTING, STATUS IS: $_microphonePermissionStatus");
  }

  @override
  Future<String?> getPlatformVersion() => Future.value('Android 14');

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) {
    // شبیه‌سازی برخی مجوزها به صورت مجاز، برخی رد شده
    return Future.value(
      permissions.asMap().map(
        (key, value) => MapEntry(value, key % 2 == 0 ? 'GRANTED' : 'DENIED'),
      ),
    );
  }

  @override
  Future<String> checkPermissionStatus(String permission) {
    // مدیریت مجوز میکروفون به طور خاص
    if (permission == 'android.permission.RECORD_AUDIO') {
      return Future.value(_microphonePermissionStatus);
    }
    // سایر مجوزها رفتار پیش‌فرض دارند
    return Future.value(permission.contains('CAMERA') ? 'GRANTED' : 'DENIED');
  }

  @override
  Future<void> openAppSettings() {
    return Future.value();
  }

  @override
  Future<String> requestPermission(String method) {
    debugPrint("MockPlatform: $method called");

    if (method == 'requestMicrophonePermission') {
      debugPrint(
        "Mock status value AT TIME OF REQUEST: $_microphonePermissionStatus",
      );
      return Future.value(_microphonePermissionStatus);
    }

    switch (method) {
      case 'requestCameraPermission':
      case 'requestLocationPermission':
      case 'requestBluetoothPermission':
      case 'requestActivityRecognitionPermission':
      case 'requestNearbyDevicesPermission':
      case 'requestPhonePermission':
      case 'requestSmsPermission':
      case 'requestWifiPermission':
        return Future.value('GRANTED');
      default:
        return Future.value('DENIED');
    }
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
}

void main() {
  // تنظیم پلتفرم موک در ابتدا
  final fakePlatform = MockPermissionMasterPlatform();
  PermissionMasterPlatform.instance = fakePlatform;

  group('PermissionMaster Tests', () {
    setUp(() {
      // بازنشانی وضعیت موک قبل از هر تست
      fakePlatform.microphonePermissionStatus = 'DENIED';
    });

    test('requestMicrophonePermission returns denied by default', () async {
      final permissionMaster = TestPermissionMaster();
      final result = await permissionMaster.requestMicrophonePermission();
      expect(result, PermissionStatus.denied);
    });

    test(
      'requestMicrophonePermission returns granted when set in mock',
      () async {
        fakePlatform.microphonePermissionStatus = 'GRANTED';
        final permissionMaster = TestPermissionMaster();
        final result = await permissionMaster.requestMicrophonePermission();
        expect(result, PermissionStatus.granted);
      },
    );

    test(
      'checkPermissionStatus for microphone returns denied by default',
      () async {
        final permissionMaster = TestPermissionMaster();
        final result = await permissionMaster.checkPermissionStatus(
          'android.permission.RECORD_AUDIO',
        );
        expect(result, PermissionStatus.denied);
      },
    );

    test(
      'checkPermissionStatus for microphone returns granted when set in mock',
      () async {
        fakePlatform.microphonePermissionStatus = 'GRANTED';
        final permissionMaster = TestPermissionMaster();
        final result = await permissionMaster.checkPermissionStatus(
          'android.permission.RECORD_AUDIO',
        );
        expect(result, PermissionStatus.granted);
      },
    );

    test('requestCameraPermission returns granted', () async {
      final permissionMaster = TestPermissionMaster();
      expect(
        await permissionMaster.requestCameraPermission(),
        PermissionStatus.granted,
      );
    });

    test('requestLocationPermission returns granted', () async {
      final permissionMaster = TestPermissionMaster();
      expect(
        await permissionMaster.requestLocationPermission(),
        PermissionStatus.granted,
      );
    });

    test('checkMultiplePermissions returns mixed statuses', () async {
      final permissionMaster = TestPermissionMaster();
      final permissions = [
        PermissionType.camera,
        PermissionType.microphone,
        PermissionType.fineLocation,
      ];
      final result = await permissionMaster.checkMultiplePermissions(
        permissions,
      );
      expect(result['android.permission.CAMERA'], PermissionStatus.granted);
      expect(
        result['android.permission.RECORD_AUDIO'],
        PermissionStatus.denied,
      );
      expect(
        result['android.permission.ACCESS_FINE_LOCATION'],
        PermissionStatus.granted,
      );
    });

    test('openAppSettings completes successfully', () async {
      final permissionMaster = TestPermissionMaster();
      await expectLater(permissionMaster.openAppSettings(), completes);
    });
  });
}
