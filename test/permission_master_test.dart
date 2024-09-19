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
  Future<bool> requestCameraPermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestLocationPermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestMicrophonePermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPhotosPermission() {
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
