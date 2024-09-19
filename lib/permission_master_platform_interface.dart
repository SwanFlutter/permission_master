import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'permission_master_method_channel.dart';

abstract class PermissionMasterPlatform extends PlatformInterface {
  /// Constructs a PermissionMasterPlatform.
  PermissionMasterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PermissionMasterPlatform _instance = MethodChannelPermissionMaster();

  /// The default instance of [PermissionMasterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPermissionMaster].
  static PermissionMasterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PermissionMasterPlatform] when
  /// they register themselves.
  static set instance(PermissionMasterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<bool> requestCameraPermission() {
    throw UnimplementedError(
        'requestCameraPermission() has not been implemented.');
  }

  Future<bool> requestLocationPermission() {
    throw UnimplementedError(
        'requestLocationPermission() has not been implemented.');
  }

  Future<bool> requestMicrophonePermission() {
    throw UnimplementedError(
        'requestMicrophonePermission() has not been implemented.');
  }

  Future<bool> requestPhotosPermission() {
    throw UnimplementedError(
        'requestPhotosPermission() has not been implemented.');
  }
}
