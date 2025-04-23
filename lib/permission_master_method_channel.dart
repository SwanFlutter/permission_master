import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'permission_master_platform_interface.dart';

/// A class that implements the platform-specific functionality for permission handling using MethodChannel.
class MethodChannelPermissionMaster extends PermissionMasterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('permission_master');

  static BuildContext? _context;
  static BuildContext? get context => _context;

  /// Constructor - This method is executed only once.
  MethodChannelPermissionMaster() {
    _setupMethodCallHandler();
  }

  /// Sets up the method call handler to receive calls from native platforms.
  void _setupMethodCallHandler() {
    methodChannel.setMethodCallHandler((call) async {
      debugPrint('Method call from native: ${call.method}');

      switch (call.method) {
        case 'onShowRationale':
          final permission = call.arguments['permission'] as String?;
          debugPrint('Show rationale for permission: $permission');
          if (_context != null && permission != null) {
            await _showRationaleDialog(permission);
          }
          break;
        case 'openAppSettings':
          debugPrint('Native requested to open app settings');
          if (_context != null) {
            await openAppSettings();
          }
          break;
      }
    });
  }

  /// Sets the context for the permission master.
  static void setContext(BuildContext context) {
    debugPrint('Setting context for PermissionMaster');
    _context = context;
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      return await methodChannel.invokeMethod<String>('getPlatformVersion');
    } on PlatformException catch (e) {
      debugPrint('Error getting platform version: ${e.message}');
      return 'Failed to get platform version: ${e.message}';
    }
  }

  @override
  Future<String> requestPermission(String method) async {
    return _invokePermissionMethod(method);
  }

  @override
  Future<String> requestCameraPermission() async =>
      _invokePermissionMethod('requestCameraPermission');

  @override
  Future<String> requestLocationPermission() async =>
      _invokePermissionMethod('requestLocationPermission');

  @override
  Future<String> requestStoragePermission() async {
    // Handle storage permissions differently based on platform and Android version
    if (Platform.isAndroid) {
      try {
        final androidVersion = await methodChannel.invokeMethod<int>(
          'getAndroidVersion',
        );

        // For Android 13+ (API 33+)
        if (androidVersion != null && androidVersion >= 33) {
          // Request modern storage permissions
          debugPrint(
            'Using modern storage permissions for Android $androidVersion',
          );
          final result = await _invokePermissionMethod(
            'requestStoragePermission',
          );

          // Check if any of the permissions were granted
          if (result is Map<dynamic, dynamic>) {
            final values = (result as Map<dynamic, dynamic>).values.toList();
            if (values.contains('GRANTED')) {
              return 'GRANTED';
            } else if (values.contains('OPEN_SETTINGS')) {
              return 'OPEN_SETTINGS';
            } else if (values.contains('SHOW_RATIONALE')) {
              return 'SHOW_RATIONALE';
            }
            return 'DENIED';
          }
          return result;
        }
      } catch (e) {
        debugPrint('Error checking Android version: $e');
        return 'ERROR';
      }
    }

    // Default implementation for older Android versions and iOS
    try {
      return await _invokePermissionMethod('requestStoragePermission');
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return 'ERROR';
    }
  }

  @override
  Future<String> requestBluetoothPermission() async =>
      _invokePermissionMethod('requestBluetoothPermission');

  @override
  Future<String> requestSensorsPermission() async =>
      _invokePermissionMethod('requestSensorsPermission');

  @override
  Future<String> requestWifiPermission() async =>
      _invokePermissionMethod('requestWifiPermission');

  @override
  Future<String> requestContactsPermission() async =>
      _invokePermissionMethod('requestContactsPermission');

  @override
  Future<String> requestSmsPermission() async =>
      _invokePermissionMethod('requestSmsPermission');

  @override
  Future<String> requestNotificationPermission() async =>
      _invokePermissionMethod('requestNotificationPermission');

  @override
  Future<String> requestAlarmPermission() async {
    // Handle alarm permission differently based on platform
    if (Platform.isIOS) {
      // On iOS, we use notifications for alarms
      debugPrint(
        'Using notification permission for alarm functionality on iOS',
      );
      final result = await _invokePermissionMethod(
        'requestNotificationPermission',
      );
      return result;
    } else if (Platform.isAndroid) {
      try {
        final androidVersion = await methodChannel.invokeMethod<int>(
          'getAndroidVersion',
        );

        // Android 12+ has additional restrictions
        if (androidVersion != null && androidVersion >= 31) {
          // For Android 12+, check if the app can schedule exact alarms
          final canScheduleExactAlarms = await methodChannel.invokeMethod<bool>(
            'canScheduleExactAlarms',
          );
          if (canScheduleExactAlarms == false) {
            // If not, we need to direct the user to system settings
            if (_context != null) {
              await _showAlarmPermissionDialog();
            }
            return 'OPEN_SETTINGS';
          }
        }
      } catch (e) {
        debugPrint('Error checking alarm permissions: $e');
      }
    }

    // Default implementation
    return _invokePermissionMethod('requestAlarmPermission');
  }

  @override
  Future<String> requestMicrophonePermission() async =>
      _invokePermissionMethod('requestMicrophonePermission');

  @override
  Future<String> requestCalendarPermission() async =>
      _invokePermissionMethod('requestCalendarPermission');

  @override
  Future<String> requestPhonePermission() async => _invokePermissionMethod(
    Platform.isIOS ? 'unsupportedPermission' : 'requestPhonePermission',
  );

  @override
  Future<String> requestActivityRecognitionPermission() async =>
      _invokePermissionMethod('requestActivityRecognitionPermission');

  @override
  Future<String> requestNearbyDevicesPermission() async =>
      _invokePermissionMethod(
        Platform.isIOS
            ? 'requestBluetoothPermission'
            : 'requestNearbyDevicesPermission',
      );

  /// Shows a dialog specifically for alarm permissions on newer Android versions
  Future<void> _showAlarmPermissionDialog() async {
    if (_context == null) return;

    final bool? result = await showDialog<bool>(
      context: _context!,
      builder:
          (context) => AlertDialog(
            title: const Text('Alarm Permission Required'),
            content: const Text(
              'To schedule alarms, this app needs permission to schedule exact alarms. '
              'You will be redirected to system settings to enable this.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        await methodChannel.invokeMethod('openAlarmSettings');
      } catch (e) {
        debugPrint('Failed to open alarm settings: $e');
        await openAppSettings();
      }
    }
  }

  /// Invokes a permission method and handles the result.
  Future<String> _invokePermissionMethod(String method) async {
    try {
      debugPrint('Invoking permission method: $method');

      // Handle unsupported permissions on specific platforms
      if (method == 'unsupportedPermission') {
        return 'NOT_SUPPORTED';
      }

      final result = await methodChannel.invokeMethod<dynamic>(method);
      debugPrint('Permission method result: $result');

      if (result is bool) {
        return result ? 'GRANTED' : 'DENIED';
      } else if (result is Map) {
        return result.values.first as String;
      }
      return result as String? ?? 'DENIED';
    } on PlatformException catch (e) {
      debugPrint('Error requesting permission: ${e.message}');
      // Check for specific platform errors
      if (e.code == 'PERMISSION_NOT_FOUND') {
        return 'NOT_SUPPORTED';
      }
      return 'ERROR';
    }
  }

  /// Shows a dialog explaining why a permission is needed.
  Future<void> _showRationaleDialog(String permission) async {
    if (_context == null) {
      debugPrint('Cannot show rationale dialog: context is null');
      return;
    }

    String permissionName = permission;
    // Make permission names more user-friendly
    if (permission.contains('.')) {
      permissionName = permission.split('.').last;
    }

    await showDialog(
      context: _context!,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Needed'),
            content: Text(
              'This app needs $permissionName permission to function properly.',
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Future<String> checkPermissionStatus(String permission) async {
    try {
      debugPrint('Checking permission status for: $permission');

      // Special handling for storage on newer Android versions
      if (permission == 'android.permission.READ_EXTERNAL_STORAGE' ||
          permission == 'android.permission.WRITE_EXTERNAL_STORAGE') {
        if (Platform.isAndroid) {
          try {
            final androidVersion = await methodChannel.invokeMethod<int>(
              'getAndroidVersion',
            );
            if (androidVersion != null && androidVersion >= 30) {
              // For Android 11+, check whether we have modern storage access
              final hasAccess = await methodChannel.invokeMethod<bool>(
                'hasModernStorageAccess',
              );
              return hasAccess == true ? 'GRANTED' : 'DENIED';
            }
          } catch (e) {
            debugPrint('Error checking modern storage access: $e');
          }
        }
      }

      // Special handling for alarm permission
      if (permission == 'android.permission.SET_ALARM') {
        if (Platform.isAndroid) {
          try {
            final androidVersion = await methodChannel.invokeMethod<int>(
              'getAndroidVersion',
            );
            if (androidVersion != null && androidVersion >= 31) {
              // For Android 12+, check if we can schedule exact alarms
              final canSchedule = await methodChannel.invokeMethod<bool>(
                'canScheduleExactAlarms',
              );
              return canSchedule == true ? 'GRANTED' : 'DENIED';
            }
          } catch (e) {
            debugPrint('Error checking alarm permission: $e');
          }
        } else if (Platform.isIOS) {
          // On iOS, check notification permission instead
          return await checkPermissionStatus('ios.permission.NOTIFICATIONS');
        }
      }

      // Handle platform-specific permission names
      String platformPermission = permission;
      if (Platform.isIOS && permission.startsWith('android.')) {
        // Map Android permission to iOS equivalent if needed
        switch (permission) {
          case 'android.permission.READ_PHONE_STATE':
            return 'NOT_SUPPORTED';
          // Add other mappings as needed
        }
      }

      final result = await methodChannel.invokeMethod<String>(
        'checkPermissionStatus',
        {'permission': platformPermission},
      );
      debugPrint('Permission status result: $result');
      return result ?? 'DENIED';
    } on PlatformException catch (e) {
      debugPrint('Error checking permission status: ${e.message}');
      if (e.code == 'PERMISSION_NOT_FOUND') {
        return 'NOT_SUPPORTED';
      }
      return 'ERROR';
    }
  }

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) async {
    try {
      debugPrint('Checking multiple permissions: $permissions');

      // Filter out platform-specific permissions that aren't relevant
      List<String> platformPermissions =
          permissions.where((permission) {
            if (Platform.isIOS && permission.startsWith('android.')) {
              return false;
            }
            if (Platform.isAndroid && permission.startsWith('ios.')) {
              return false;
            }
            return true;
          }).toList();

      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'checkMultiplePermissions',
        {'permissions': platformPermissions},
      );
      debugPrint('Multiple permissions result: $result');
      return result?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          {};
    } on PlatformException catch (e) {
      debugPrint('Error checking multiple permissions: ${e.message}');
      return {};
    }
  }

  @override
  Future<void> openAppSettings() async {
    try {
      debugPrint('Flutter: Attempting to open app settings');
      final result = await methodChannel.invokeMethod('openAppSettings');
      debugPrint('Flutter: Open app settings result: $result');
    } catch (e) {
      debugPrint('Flutter: Error opening app settings: $e');
      _tryAlternativeOpenSettings();
    }
  }

  /// Alternative method to open app settings.
  void _tryAlternativeOpenSettings() {
    try {
      debugPrint('Trying alternative method to open app settings');
      if (_context != null) {
        showDialog(
          context: _context!,
          builder:
              (context) => AlertDialog(
                title: const Text('Could not open settings'),
                content: const Text(
                  'Please open your device settings and enable the required permissions manually.',
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      debugPrint('Alternative open settings also failed: $e');
    }
  }
}
