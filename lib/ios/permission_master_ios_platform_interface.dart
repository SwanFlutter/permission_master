import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'permission_master_ios_method_channel.dart';

abstract class PermissionMasterIosPlatform extends PlatformInterface {
  /// Constructs a PermissionMasterIosPlatform.
  PermissionMasterIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static PermissionMasterIosPlatform _instance =
      MethodChannelPermissionMasterIos();

  /// The default instance of [PermissionMasterIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelPermissionMasterIos].
  static PermissionMasterIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PermissionMasterIosPlatform] when
  /// they register themselves.
  static set instance(PermissionMasterIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String> requestCameraPermission() {
    throw UnimplementedError(
      'requestCameraPermission() has not been implemented.',
    );
  }

  Future<String> requestPhotosPermission() {
    throw UnimplementedError(
      'requestPhotosPermission() has not been implemented.',
    );
  }

  Future<String> requestLocationPermission() {
    throw UnimplementedError(
      'requestLocationPermission() has not been implemented.',
    );
  }

  Future<String> requestContactsPermission() {
    throw UnimplementedError(
      'requestContactsPermission() has not been implemented.',
    );
  }

  Future<String> requestBluetoothPermission() {
    throw UnimplementedError(
      'requestBluetoothPermission() has not been implemented.',
    );
  }

  Future<String> requestMicrophonePermission() {
    throw UnimplementedError(
      'requestMicrophonePermission() has not been implemented.',
    );
  }

  Future<String> requestNotificationPermission() {
    throw UnimplementedError(
      'requestNotificationPermission() has not been implemented.',
    );
  }

  Future<String> requestCalendarPermission() {
    throw UnimplementedError(
      'requestCalendarPermission() has not been implemented.',
    );
  }

  Future<String> requestMotionPermission() {
    throw UnimplementedError(
      'requestMotionPermission() has not been implemented.',
    );
  }

  Future<String> requestSpeechPermission() {
    throw UnimplementedError(
      'requestSpeechPermission() has not been implemented.',
    );
  }

  Future<String> requestRemindersPermission() {
    throw UnimplementedError(
      'requestRemindersPermission() has not been implemented.',
    );
  }

  Future<String> requestMusicPermission() {
    throw UnimplementedError(
      'requestMusicPermission() has not been implemented.',
    );
  }

  Future<String> requestHealthPermission() {
    throw UnimplementedError(
      'requestHealthPermission() has not been implemented.',
    );
  }

  Future<String> checkPermissionStatus(String permission) {
    throw UnimplementedError(
      'checkPermissionStatus() has not been implemented.',
    );
  }

  Future<bool> openAppSettings() {
    throw UnimplementedError('openAppSettings() has not been implemented.');
  }
}
