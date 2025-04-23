import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'permission_master_method_channel.dart';

/// The interface that implementations of permission_master must implement.
///
/// Platform implementations should extend this class rather than implement it as
/// permission_master does not consider newly added methods to be breaking changes.
abstract class PermissionMasterPlatform extends PlatformInterface {
  /// Constructs a PermissionMasterPlatform.
  PermissionMasterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PermissionMasterPlatform _instance = MethodChannelPermissionMaster();

  /// The default instance of [PermissionMasterPlatform] to use.
  static PermissionMasterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PermissionMasterPlatform] when
  /// they register themselves.
  static set instance(PermissionMasterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets the context for showing dialogs related to permissions
  static void setContext(BuildContext context) {
    MethodChannelPermissionMaster.setContext(context);
  }

  /// Gets the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Generic method to request any permission
  Future<String> requestPermission(String method);

  /// Request camera permission
  Future<String> requestCameraPermission();

  /// Request location permission
  Future<String> requestLocationPermission();

  /// Request storage permission
  Future<String> requestStoragePermission();

  /// Request bluetooth permission
  Future<String> requestBluetoothPermission();

  /// Request body sensors permission
  Future<String> requestSensorsPermission();

  /// Request wifi permission
  Future<String> requestWifiPermission();

  /// Request contacts permission
  Future<String> requestContactsPermission();

  /// Request SMS permission
  Future<String> requestSmsPermission();

  /// Request notification permission
  Future<String> requestNotificationPermission();

  /// Request alarm permission
  Future<String> requestAlarmPermission();

  /// Request microphone permission
  Future<String> requestMicrophonePermission();

  /// Request calendar permission
  Future<String> requestCalendarPermission();

  /// Request phone permission
  Future<String> requestPhonePermission();

  /// Request activity recognition permission
  Future<String> requestActivityRecognitionPermission();

  /// Request nearby devices permission
  Future<String> requestNearbyDevicesPermission();

  /// Check status of a specific permission
  Future<String> checkPermissionStatus(String permission);

  /// Check status of multiple permissions
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  );

  /// Open app settings
  Future<void> openAppSettings();
}
