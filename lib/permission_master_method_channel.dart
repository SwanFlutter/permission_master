// ignore_for_file: override_on_non_overriding_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'permission_master_platform_interface.dart';

/// A class that implements the platform-specific functionality for permission handling using MethodChannel.
class MethodChannelPermissionMaster extends PermissionMasterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('permission_master');

  /// Static context for showing dialogs
  static BuildContext? _context;

  /// Sets the context for showing dialogs
  static set context(BuildContext? context) {
    _context = context;
    debugPrint('Setting context for PermissionMaster');
  }

  /// Gets the current context
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
        case 'onUnsupportedVersion':
          final permission = call.arguments['permission'] as String?;
          final message = call.arguments['message'] as String?;
          final minSdkVersion = call.arguments['minSdkVersion'] as int?;

          debugPrint(
            'Unsupported version for permission: $permission, requires: $minSdkVersion',
          );
          if (_context != null && permission != null && message != null) {
            await _showUnsupportedVersionDialog(permission, message);
          }
          break;
        case 'onAlarmPermissionNeeded':
          debugPrint('Alarm permission needed');
          break;
        default:
          debugPrint('Unhandled method call: ${call.method}');
      }
      return null;
    });
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
  Future<String> requestLocationPermission() async {
    debugPrint('Requesting location permission');
    try {
      final result = await methodChannel.invokeMethod<dynamic>(
        'requestLocationPermission',
      );
      debugPrint('Location permission result: $result');

      if (result is bool) {
        return result ? 'GRANTED' : 'DENIED';
      } else if (result is Map) {
        // For map results, check if any permission is granted
        final values = result.values.toList();
        debugPrint('Location permission values: $values');

        if (values.contains('GRANTED')) {
          return 'GRANTED';
        } else if (values.contains('OPEN_SETTINGS')) {
          return 'OPEN_SETTINGS';
        } else if (values.contains('SHOW_RATIONALE')) {
          return 'SHOW_RATIONALE';
        }
        return 'DENIED';
      }

      return result as String? ?? 'DENIED';
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return 'ERROR';
    }
  }

  @override
  Future<String> requestStoragePermission() async {
    // Handle storage permissions differently based on platform and Android version
    if (Platform.isAndroid) {
      try {
        final androidVersion = await methodChannel.invokeMethod<int>(
          'getAndroidVersion',
        );

        debugPrint('Requesting storage permission on Android $androidVersion');

        // Process based on Android version
        if (androidVersion != null) {
          // Request storage permissions through the native implementation
          final result = await methodChannel.invokeMethod<dynamic>(
            'requestStoragePermission',
          );

          debugPrint('Storage permission result: $result');

          // Check if any of the permissions were granted
          if (result is Map<dynamic, dynamic>) {
            final values = result.values.toList();
            debugPrint('Storage permission values: $values');

            // If any permission is granted, consider the overall result as granted
            if (values.contains('GRANTED')) {
              return 'GRANTED';
            } else if (values.contains('OPEN_SETTINGS')) {
              return 'OPEN_SETTINGS';
            } else if (values.contains('SHOW_RATIONALE')) {
              return 'SHOW_RATIONALE';
            }
            return 'DENIED';
          } else if (result is bool) {
            // Handle boolean result
            return result ? 'GRANTED' : 'DENIED';
          } else if (result is String) {
            // Handle string result
            return result;
          }

          // Default to denied for unknown result types
          return 'DENIED';
        } else {
          // If we couldn't determine the Android version, use the standard approach
          debugPrint(
            'Could not determine Android version, using standard approach',
          );
          return await _invokePermissionMethod('requestStoragePermission');
        }
      } catch (e) {
        debugPrint('Error requesting storage permission: $e');
        return 'ERROR';
      }
    } else if (Platform.isIOS) {
      // On iOS, we use photo library permissions
      debugPrint('Requesting photo library permission on iOS');
      return await _invokePermissionMethod('requestStoragePermission');
    }

    // Default implementation for other platforms
    try {
      return await _invokePermissionMethod('requestStoragePermission');
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return 'ERROR';
    }
  }

  @override
  Future<String> requestManageExternalStoragePermission() async =>
      _invokePermissionMethod('requestManageExternalStorage');

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
    debugPrint('Requesting alarm permission');

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
        debugPrint('Android version: $androidVersion');

        // Android 12+ has additional restrictions
        if (androidVersion != null && androidVersion >= 31) {
          debugPrint(
            'Android 12+ detected, checking if can schedule exact alarms',
          );

          // First check if we have a saved permission status
          final savedStatus = await methodChannel
              .invokeMethod<String>('storage_read', {
                'key':
                    'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
                'defaultValue': '',
              });

          debugPrint('Saved alarm permission status: $savedStatus');

          if (savedStatus == 'GRANTED') {
            debugPrint('Using saved GRANTED status for alarm permission');
            return 'GRANTED';
          }

          // For Android 12+, check if the app can schedule exact alarms
          final canScheduleExactAlarms = await methodChannel.invokeMethod<bool>(
            'canScheduleExactAlarms',
          );
          debugPrint('Can schedule exact alarms: $canScheduleExactAlarms');

          if (canScheduleExactAlarms == true) {
            // Save the permission status
            await methodChannel.invokeMethod<bool>('storage_write', {
              'key':
                  'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
              'value': 'GRANTED',
            });
            return 'GRANTED';
          }

          // If we can't schedule exact alarms, we need to request the permission
          debugPrint('Need to request alarm permission');

          // Open the alarm settings immediately
          await methodChannel.invokeMethod('openAlarmSettings');

          // Show a waiting dialog immediately
          if (_context != null) {
            // Show a waiting dialog
            await showDialog(
              context: _context!,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Grant Permission'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Please tap "Allow" or "Allow precise alarms" on the settings screen.',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('I\'ve Granted Permission'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          } else {
            // If no context, just wait a bit longer
            await Future.delayed(const Duration(seconds: 5));
          }

          // Wait a bit more to ensure the permission status is updated
          await Future.delayed(const Duration(milliseconds: 500));

          // Check if the permission was granted
          final checkResult = await methodChannel.invokeMethod<bool>(
            'checkAlarmPermissionAfterSettings',
          );
          debugPrint('Alarm permission after settings: $checkResult');

          // Try again if still not granted
          if (checkResult != true) {
            debugPrint('Permission still not granted, checking again...');
            await Future.delayed(const Duration(seconds: 1));
            final secondCheck = await methodChannel.invokeMethod<bool>(
              'checkAlarmPermissionAfterSettings',
            );
            debugPrint('Second check result: $secondCheck');

            if (secondCheck == true) {
              // Save the result as granted
              await methodChannel.invokeMethod<bool>('storage_write', {
                'key':
                    'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
                'value': 'GRANTED',
              });
              return 'GRANTED';
            }
          }

          // Save the result
          final status = checkResult == true ? 'GRANTED' : 'DENIED';
          await methodChannel.invokeMethod<bool>('storage_write', {
            'key': 'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
            'value': status,
          });

          return status;
        } else {
          // For Android 11 and below, no special permission is needed
          debugPrint('Android 11 or below, no special alarm permission needed');

          // Save the granted status
          await methodChannel.invokeMethod<bool>('storage_write', {
            'key': 'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
            'value': 'GRANTED',
          });

          return 'GRANTED';
        }
      } catch (e) {
        debugPrint('Error handling alarm permission: $e');
        return 'ERROR';
      }
    }

    // Fallback to the native implementation
    try {
      debugPrint('Using native implementation for alarm permission');
      final result = await methodChannel.invokeMethod<dynamic>(
        'requestAlarmPermission',
      );
      debugPrint('Alarm permission result from native: $result');

      // If we get a boolean result, convert it to a string status
      if (result is bool) {
        final status = result ? 'GRANTED' : 'DENIED';

        // Save the status
        await methodChannel.invokeMethod<bool>('storage_write', {
          'key': 'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
          'value': status,
        });

        return status;
      }

      return 'DENIED';
    } catch (e) {
      debugPrint('Error requesting alarm permission: $e');
      return 'ERROR';
    }
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
  /// Returns true if the user chose to open settings, false otherwise
  Future<bool> showAlarmPermissionDialog() async {
    if (_context == null) return false;

    debugPrint('Showing alarm permission dialog');

    final bool? result = await showDialog<bool>(
      context: _context!,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (context) => AlertDialog(
        title: const Text('Alarm Permission Required'),
        content: const Text(
          'To schedule alarms, this app needs permission to schedule exact alarms.\n\n'
          'You will be redirected to system settings. Please tap "Allow" or "Allow precise alarms" on the next screen.',
        ),
        actions: [
          TextButton(
            child: const Text('Not Now'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    debugPrint('Alarm permission dialog result: $result');

    // If the user chose to open settings
    if (result == true) {
      try {
        debugPrint('Opening alarm settings');

        // Show a toast to guide the user
        if (_context != null) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            const SnackBar(
              content: Text('Please tap "Allow" on the next screen'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        return true;
      } catch (e) {
        debugPrint('Failed to show guidance for alarm settings: $e');
        return true;
      }
    }

    return false;
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
      } else if (e.code == 'VERSION_ERROR') {
        // Handle version-specific errors
        return 'UNSUPPORTED';
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
      builder: (context) => AlertDialog(
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

  /// Shows a dialog explaining that a permission is not supported on the current Android version.
  Future<void> _showUnsupportedVersionDialog(
    String permission,
    String message,
  ) async {
    if (_context == null) {
      debugPrint('Cannot show unsupported version dialog: context is null');
      return;
    }

    String permissionName = permission;
    // Make permission names more user-friendly
    if (permission.contains('.')) {
      permissionName = permission.split('.').last;
    }

    await showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: const Text('Permission Not Supported'),
        content: Text(
          'The $permissionName permission is not supported on your device.\n\n$message',
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

      // Special handling for storage permissions across all Android versions
      if (permission == 'android.permission.READ_EXTERNAL_STORAGE' ||
          permission == 'android.permission.WRITE_EXTERNAL_STORAGE' ||
          permission == 'android.permission.READ_MEDIA_IMAGES' ||
          permission == 'android.permission.READ_MEDIA_VIDEO' ||
          permission == 'android.permission.READ_MEDIA_AUDIO') {
        if (Platform.isAndroid) {
          try {
            final androidVersion = await methodChannel.invokeMethod<int>(
              'getAndroidVersion',
            );
            debugPrint(
              'Checking storage permission on Android $androidVersion',
            );

            // Use hasModernStorageAccess which handles all Android versions appropriately
            final hasAccess = await methodChannel.invokeMethod<bool>(
              'hasModernStorageAccess',
            );
            debugPrint('Storage access check result: $hasAccess');
            return hasAccess == true ? 'GRANTED' : 'DENIED';
          } catch (e) {
            debugPrint('Error checking storage access: $e');
          }
        }
      }

      // Special handling for alarm permission
      if (permission == 'android.permission.SET_ALARM' ||
          permission == 'android.permission.SCHEDULE_EXACT_ALARM') {
        if (Platform.isAndroid) {
          try {
            // First check if we have a saved permission status
            final savedStatus = await methodChannel.invokeMethod<String>(
              'storage_read',
              {
                'key':
                    'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
                'defaultValue': '',
              },
            );

            debugPrint('Saved alarm permission status: $savedStatus');

            if (savedStatus == 'GRANTED') {
              debugPrint('Using saved GRANTED status for alarm permission');
              return 'GRANTED';
            }

            final androidVersion = await methodChannel.invokeMethod<int>(
              'getAndroidVersion',
            );

            if (androidVersion != null && androidVersion >= 31) {
              // For Android 12+, check if we can schedule exact alarms
              final canSchedule = await methodChannel.invokeMethod<bool>(
                'canScheduleExactAlarms',
              );

              // Save the status
              final status = canSchedule == true ? 'GRANTED' : 'DENIED';
              await methodChannel.invokeMethod<bool>('storage_write', {
                'key':
                    'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
                'value': status,
              });

              return status;
            } else {
              // For Android 11 and below, no special permission is needed
              await methodChannel.invokeMethod<bool>('storage_write', {
                'key':
                    'permission_android.permission.SCHEDULE_EXACT_ALARM_status',
                'value': 'GRANTED',
              });
              return 'GRANTED';
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
      List<String> platformPermissions = permissions.where((permission) {
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
          builder: (context) => AlertDialog(
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

  /// Clears all permission request counts to allow fresh permission requests
  Future<bool> clearPermissionCounts() async {
    try {
      debugPrint('Clearing permission request counts');
      final result = await methodChannel.invokeMethod<bool>(
        'clearPermissionCounts',
      );
      debugPrint('Clear permission counts result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error clearing permission counts: ${e.message}');
      return false;
    }
  }

  @override
  void setContext(BuildContext context) {
    MethodChannelPermissionMaster.context = context;
  }
}
