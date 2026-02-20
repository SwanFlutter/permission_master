import 'permission_master_ios_platform_interface.dart';
import 'src/get_storage_bridge.dart';
import 'src/permission_status.dart';
import 'src/permission_type.dart';

export 'src/get_storage_bridge.dart';
export 'src/permission_status.dart';
export 'src/permission_type.dart';

/// Main class for iOS permission management
class PermissionMasterIos {
  final _storage = GetStorageBridge();

  /// Get iOS platform version
  Future<String?> getPlatformVersion() {
    return PermissionMasterIosPlatform.instance.getPlatformVersion();
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestCameraPermission();
    return _parseStatus(status);
  }

  /// Request photos library permission
  Future<PermissionStatus> requestPhotosPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestPhotosPermission();
    return _parseStatus(status);
  }

  /// Request location permission
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestLocationPermission();
    return _parseStatus(status);
  }

  /// Request contacts permission
  Future<PermissionStatus> requestContactsPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestContactsPermission();
    return _parseStatus(status);
  }

  /// Request bluetooth permission
  Future<PermissionStatus> requestBluetoothPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestBluetoothPermission();
    return _parseStatus(status);
  }

  /// Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestMicrophonePermission();
    return _parseStatus(status);
  }

  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestNotificationPermission();
    return _parseStatus(status);
  }

  /// Request calendar permission
  Future<PermissionStatus> requestCalendarPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestCalendarPermission();
    return _parseStatus(status);
  }

  /// Request motion & fitness permission
  Future<PermissionStatus> requestMotionPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestMotionPermission();
    return _parseStatus(status);
  }

  /// Request speech recognition permission
  Future<PermissionStatus> requestSpeechPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestSpeechPermission();
    return _parseStatus(status);
  }

  /// Request reminders permission
  Future<PermissionStatus> requestRemindersPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestRemindersPermission();
    return _parseStatus(status);
  }

  /// Request media library permission
  Future<PermissionStatus> requestMusicPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestMusicPermission();
    return _parseStatus(status);
  }

  /// Request health data permission
  Future<PermissionStatus> requestHealthPermission() async {
    final status = await PermissionMasterIosPlatform.instance
        .requestHealthPermission();
    return _parseStatus(status);
  }

  /// Check permission status without requesting
  Future<PermissionStatus> checkPermissionStatus(PermissionType type) async {
    final status = await PermissionMasterIosPlatform.instance
        .checkPermissionStatus(type.value);
    return _parseStatus(status);
  }

  /// Get storage instance for custom data persistence
  GetStorageBridge get storage => _storage;

  /// Open app settings page
  /// Use this when permission is denied and user needs to enable it manually
  Future<bool> openAppSettings() async {
    return await PermissionMasterIosPlatform.instance.openAppSettings();
  }
}

PermissionStatus _parseStatus(String status) {
  switch (status) {
    case 'granted':
      return PermissionStatus.granted;
    case 'denied':
      return PermissionStatus.denied;
    case 'restricted':
      return PermissionStatus.restricted;
    case 'limited':
      return PermissionStatus.limited;
    case 'unsupported':
      return PermissionStatus.unsupported;
    case 'openSettings':
      return PermissionStatus.openSettings;
    case 'error':
      return PermissionStatus.error;
    default:
      return PermissionStatus.notDetermined;
  }
}
