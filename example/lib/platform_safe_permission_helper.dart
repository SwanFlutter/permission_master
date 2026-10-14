/*import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

/// A safe wrapper for permission requests that handles platform-specific issues
class PlatformSafePermissionHelper {
  final PermissionMaster _permissionMaster = PermissionMaster();

  /// Safely request camera permission across all platforms
  Future<PermissionStatus> requestCameraPermission() async {
    try {
      if (kIsWeb) {
        return await _permissionMaster.requestCameraPermissionWeb();
      } else if (Platform.isWindows) {
        return await _permissionMaster.requestCameraPermissionWindows();
      } else if (Platform.isMacOS) {
        return await _permissionMaster.requestCameraPermissionMac();
      } else if (Platform.isLinux) {
        return await _permissionMaster.requestCameraPermissionLinux();
      } else {
        // For mobile platforms, use the generic method
        return await _permissionMaster.requestCameraPermission();
      }
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return PermissionStatus.error;
    }
  }

  /// Safely request microphone permission across all platforms
  Future<PermissionStatus> requestMicrophonePermission() async {
    try {
      if (kIsWeb) {
        return await _permissionMaster.requestMicrophonePermissionWeb();
      } else if (Platform.isWindows) {
        return await _permissionMaster.requestMicrophonePermissionWindows();
      } else if (Platform.isMacOS) {
        return await _permissionMaster.requestMicrophonePermissionMac();
      } else if (Platform.isLinux) {
        return await _permissionMaster.requestMicrophonePermissionLinux();
      } else {
        return await _permissionMaster.requestMicrophonePermission();
      }
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return PermissionStatus.error;
    }
  }

  /// Safely request location permission across all platforms
  Future<PermissionStatus> requestLocationPermission() async {
    try {
      if (kIsWeb) {
        return await _permissionMaster.requestLocationPermissionWeb();
      } else if (Platform.isWindows) {
        return await _permissionMaster.requestLocationPermissionWindows();
      } else if (Platform.isMacOS) {
        return await _permissionMaster.requestLocationPermissionMac();
      } else if (Platform.isLinux) {
        return await _permissionMaster.requestLocationPermissionLinux();
      } else {
        return await _permissionMaster.requestLocationPermission();
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return PermissionStatus.error;
    }
  }

  /// Safely request storage permission across all platforms
  Future<PermissionStatus> requestStoragePermission() async {
    try {
      if (kIsWeb) {
        return await _permissionMaster.requestStoragePermissionWeb();
      } else if (Platform.isWindows) {
        return await _permissionMaster.requestStoragePermissionWindows();
      } else if (Platform.isMacOS) {
        return await _permissionMaster.requestStoragePermissionMac();
      } else if (Platform.isLinux) {
        return await _permissionMaster.requestStoragePermissionLinux();
      } else {
        return await _permissionMaster.requestStoragePermission();
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return PermissionStatus.error;
    }
  }

  /// Safely request notification permission across all platforms
  Future<PermissionStatus> requestNotificationPermission() async {
    try {
      if (kIsWeb) {
        return await _permissionMaster.requestNotificationPermissionWeb();
      } else if (Platform.isWindows) {
        return await _permissionMaster.requestNotificationPermissionWindows();
      } else if (Platform.isMacOS) {
        return await _permissionMaster.requestNotificationPermissionMac();
      } else if (Platform.isLinux) {
        return await _permissionMaster.requestNotificationPermissionLinux();
      } else {
        return await _permissionMaster.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionStatus.error;
    }
  }

  /// Safely check multiple permissions with fallback
  Future<Map<String, PermissionStatus>> checkMultiplePermissionsSafe(
    List<PermissionType> permissions,
  ) async {
    try {
      // Try the generic method first
      final result = await _permissionMaster.checkMultiplePermissions(
        permissions,
      );
      return result;
    } catch (e) {
      debugPrint('Generic checkMultiplePermissions failed: $e');

      // Fallback: check each permission individually
      final Map<String, PermissionStatus> results = {};

      for (final permission in permissions) {
        try {
          PermissionStatus status;
          switch (permission) {
            case PermissionType.camera:
              status = await requestCameraPermission();
              break;
            case PermissionType.microphone:
              status = await requestMicrophonePermission();
              break;
            case PermissionType.fineLocation:
            case PermissionType.backgroundLocation:
              status = await requestLocationPermission();
              break;
            case PermissionType.readStorage:
            case PermissionType.writeStorage:
              status = await requestStoragePermission();
              break;
            case PermissionType.notifications:
              status = await requestNotificationPermission();
              break;
            default:
              status =
                  PermissionStatus.granted; // Default for other permissions
          }
          results[permission.value] = status;
        } catch (e) {
          debugPrint('Error checking permission ${permission.value}: $e');
          results[permission.value] = PermissionStatus.error;
        }
      }

      return results;
    }
  }

  /// Get platform version safely
  Future<String> getPlatformVersionSafe() async {
    try {
      final version = await _permissionMaster.getPlatformVersion();
      return version ?? 'Unknown';
    } catch (e) {
      debugPrint('Error getting platform version: $e');
      if (kIsWeb) {
        return 'Web';
      } else if (Platform.isWindows) {
        return 'Windows';
      } else if (Platform.isMacOS) {
        return 'macOS';
      } else if (Platform.isLinux) {
        return 'Linux';
      } else if (Platform.isAndroid) {
        return 'Android';
      } else if (Platform.isIOS) {
        return 'iOS';
      } else {
        return 'Unknown Platform';
      }
    }
  }

  /// Open app settings safely
  Future<bool> openAppSettingsSafe() async {
    try {
      await _permissionMaster.openAppSettings();
      return true;
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Set context safely
  void setContextSafe(BuildContext context) {
    try {
      PermissionMaster.setContext(context);
    } catch (e) {
      debugPrint('Error setting context: $e');
    }
  }

  /// Get current platform name
  String getCurrentPlatform() {
    if (kIsWeb) return 'Web';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Check if current platform supports a specific permission
  bool isPlatformSupported(PermissionType permission) {
    final platform = getCurrentPlatform();

    switch (permission) {
      case PermissionType.sms:
      case PermissionType.phone:
        return platform == 'Android'; // Only Android supports SMS/Phone
      case PermissionType.camera:
      case PermissionType.microphone:
      case PermissionType.fineLocation:
      case PermissionType.backgroundLocation:
      case PermissionType.readStorage:
      case PermissionType.writeStorage:
      case PermissionType.notifications:
        return true; // All platforms support these
      default:
        return true; // Default to supported
    }
  }
}
*/
