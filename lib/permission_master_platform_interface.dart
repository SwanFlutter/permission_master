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
  static void setGlobalContext(BuildContext context) {
    _instance.setContext(context);
  }

  /// Sets the context for showing dialogs related to permissions
  void setContext(BuildContext context);

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

  /// Request health permission
  Future<String> requestHealthPermission();

  /// Check status of a specific permission
  Future<String> checkPermissionStatus(String permission);

  /// Check status of multiple permissions
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  );

  /// Open app settings
  Future<void> openAppSettings();

  /// Open camera settings
  Future<void> openCameraSettings();

  /// Open microphone settings
  Future<void> openMicrophoneSettings();

  /// Open location settings
  Future<void> openLocationSettings();

  /// Open notification settings
  Future<void> openNotificationSettings();

  // Windows specific methods
  /// Request camera permission on Windows
  Future<String> requestCameraPermissionWindows();

  /// Request microphone permission on Windows
  Future<String> requestMicrophonePermissionWindows();

  /// Check camera permission status on Windows
  Future<String> checkCameraPermissionWindows();

  /// Check microphone permission status on Windows
  Future<String> checkMicrophonePermissionWindows();

  /// Check permission status on Windows
  Future<String> checkPermissionStatusWindows(String permission);

  /// Open Windows app settings
  Future<void> openAppSettingsWindows();

  /// Open Windows camera settings
  Future<void> openCameraSettingsWindows();

  /// Open Windows microphone settings
  Future<void> openMicrophoneSettingsWindows();

  // Additional Windows permission methods
  /// Request location permission on Windows
  Future<String> requestLocationPermissionWindows();

  /// Check location permission status on Windows
  Future<String> checkLocationPermissionWindows();

  /// Request notification permission on Windows
  Future<String> requestNotificationPermissionWindows();

  /// Check notification permission status on Windows
  Future<String> checkNotificationPermissionWindows();

  /// Request radios permission on Windows
  Future<String> requestRadiosPermissionWindows();

  /// Check radios permission status on Windows
  Future<String> checkRadiosPermissionWindows();

  /// Request voice activation permission on Windows
  Future<String> requestVoiceActivationPermissionWindows();

  /// Check voice activation permission status on Windows
  Future<String> checkVoiceActivationPermissionWindows();

  /// Request email permission on Windows
  Future<String> requestEmailPermissionWindows();

  /// Check email permission status on Windows
  Future<String> checkEmailPermissionWindows();

  /// Open Windows location settings
  Future<void> openLocationSettingsWindows();

  /// Open Windows notification settings
  Future<void> openNotificationSettingsWindows();

  /// Open Windows radios settings
  Future<void> openRadiosSettingsWindows();

  /// Open Windows speech settings
  Future<void> openSpeechSettingsWindows();

  // macOS specific methods
  /// Request camera permission on macOS
  Future<String> requestCameraPermissionMac();

  /// Request microphone permission on macOS
  Future<String> requestMicrophonePermissionMac();

  /// Request location permission on macOS
  Future<String> requestLocationPermissionMac();

  /// Request photo library permission on macOS
  Future<String> requestPhotoLibraryPermissionMac();

  /// Request contacts permission on macOS
  Future<String> requestContactsPermissionMac();

  /// Request notification permission on macOS
  Future<String> requestNotificationPermissionMac();

  /// Request Bluetooth permission on macOS
  Future<String> requestBluetoothPermissionMac();

  /// Request calendar permission on macOS
  Future<String> requestCalendarPermissionMac();

  /// Request reminders permission on macOS
  Future<String> requestRemindersPermissionMac();

  /// Request speech recognition permission on macOS
  Future<String> requestSpeechRecognitionPermissionMac();

  /// Check camera permission status on macOS
  Future<String> checkCameraPermissionMac();

  /// Check microphone permission status on macOS
  Future<String> checkMicrophonePermissionMac();

  /// Check location permission status on macOS
  Future<String> checkLocationPermissionMac();

  /// Check photo library permission status on macOS
  Future<String> checkPhotoLibraryPermissionMac();

  /// Check contacts permission status on macOS
  Future<String> checkContactsPermissionMac();

  /// Check notification permission status on macOS
  Future<String> checkNotificationPermissionMac();

  /// Check Bluetooth permission status on macOS
  Future<String> checkBluetoothPermissionMac();

  /// Check calendar permission status on macOS
  Future<String> checkCalendarPermissionMac();

  /// Check reminders permission status on macOS
  Future<String> checkRemindersPermissionMac();

  /// Check speech recognition permission status on macOS
  Future<String> checkSpeechRecognitionPermissionMac();

  /// Open macOS app settings
  Future<void> openAppSettingsMac();

  // Linux specific methods
  /// Request camera permission on Linux
  Future<String> requestCameraPermissionLinux();

  /// Request microphone permission on Linux
  Future<String> requestMicrophonePermissionLinux();

  /// Request location permission on Linux
  Future<String> requestLocationPermissionLinux();

  /// Request storage permission on Linux
  Future<String> requestStoragePermissionLinux();

  /// Request contacts permission on Linux
  Future<String> requestContactsPermissionLinux();

  /// Request calendar permission on Linux
  Future<String> requestCalendarPermissionLinux();

  /// Request notification permission on Linux
  Future<String> requestNotificationPermissionLinux();

  /// Request Bluetooth permission on Linux
  Future<String> requestBluetoothPermissionLinux();

  /// Request network permission on Linux
  Future<String> requestNetworkPermissionLinux();

  /// Request USB permission on Linux
  Future<String> requestUsbPermissionLinux();

  /// Open Linux app settings
  Future<void> openAppSettingsLinux();
}
