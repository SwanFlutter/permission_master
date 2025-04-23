// ignore_for_file: unreachable_switch_default

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

import 'permission_master_method_channel.dart';
import 'permission_master_platform_interface.dart';

export 'package:permission_master/src/get_storage_bridge.dart';
export 'package:permission_master/src/permission_status.dart';
export 'package:permission_master/src/permission_type.dart';

/// A class to manage and request permissions in a Flutter application.
/// Example usage:
///
/// ```dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatefulWidget {
///   @override
///   _MyAppState createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   @override
///   void initState() {
///     super.initState();
///     PermissionMaster.setContext(context);
///     _requestPermissions();
///   }
///
///   Future<void> _requestPermissions() async {
///     final permissionMaster = PermissionMaster();
///     final cameraStatus = await permissionMaster.requestCameraPermission();
///     if (cameraStatus == PermissionStatus.granted) {
///       print('Camera Permission Granted');
///     } else {
///       print('Camera Permission Denied or Error');
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         appBar: AppBar(title: Text('Permission Master Example')),
///         body: Center(child: Text('Requesting Permissions...')),
///       ),
///     );
///   }
/// }
/// ```

class PermissionMaster {
  /// Sets the context for the permission master.
  static void setContext(BuildContext context) {
    MethodChannelPermissionMaster.setContext(context);
  }

  /// Retrieves the platform version.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final platformVersion = await permissionMaster.getPlatformVersion();
  /// print('Platform Version: \$platformVersion');
  /// ```

  Future<String?> getPlatformVersion() {
    return PermissionMasterPlatform.instance.getPlatformVersion();
  }

  /// Requests a specific permission based on the provided [PermissionType].
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestPermission(PermissionType.camera);
  /// print('Camera Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestPermission({
    required PermissionType permission,
  }) async {
    switch (permission) {
      case PermissionType.camera:
        return requestCameraPermission();
      case PermissionType.fineLocation:
      case PermissionType.backgroundLocation:
        return requestLocationPermission();
      case PermissionType.readStorage:
      case PermissionType.writeStorage:
        return requestStoragePermission();
      case PermissionType.microphone:
        return requestMicrophonePermission();
      case PermissionType.contacts:
        return requestContactsPermission();
      case PermissionType.bluetooth:
      case PermissionType.bluetoothAdmin:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return requestBluetoothPermission();
      case PermissionType.bodySensors:
        return requestSensorsPermission();
      case PermissionType.accessWifi:
      case PermissionType.changeWifi:
        return requestWifiPermission();
      case PermissionType.sms:
        return requestSmsPermission();
      case PermissionType.notifications:
        return requestNotificationPermission();
      case PermissionType.alarm:
        return requestAlarmPermission();
      case PermissionType.calendar:
        return requestCalendarPermission();
      case PermissionType.phone:
        return requestPhonePermission();
      case PermissionType.activityRecognition:
        return requestActivityRecognitionPermission();
      case PermissionType.nearbyDevices:
        return requestNearbyDevicesPermission();
      default:
        throw UnsupportedError('Permission not supported');
    }
  }

  /// Requests camera permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestCameraPermission();
  /// print('Camera Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestCameraPermission() async {
    return _handlePermissionRequest(
      'requestCameraPermission',
      PermissionType.camera,
    );
  }

  /// Requests location permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestLocationPermission();
  /// print('Location Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestLocationPermission() async {
    return _handlePermissionRequest(
      'requestLocationPermission',
      PermissionType.fineLocation,
    );
  }

  /// Requests storage permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestStoragePermission();
  /// print('Storage Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestStoragePermission() async {
    return _handlePermissionRequest(
      'requestStoragePermission',
      PermissionType.readStorage,
    );
  }

  /// Requests Bluetooth permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestBluetoothPermission();
  /// print('Bluetooth Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestBluetoothPermission() async {
    return _handlePermissionRequest(
      'requestBluetoothPermission',
      PermissionType.bluetooth,
    );
  }

  /// Requests body sensors permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestSensorsPermission();
  /// print('Sensors Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestSensorsPermission() async {
    return _handlePermissionRequest(
      'requestSensorsPermission',
      PermissionType.bodySensors,
    );
  }

  /// Requests Wi-Fi permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestWifiPermission();
  /// print('Wi-Fi Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestWifiPermission() async {
    return _handlePermissionRequest(
      'requestWifiPermission',
      PermissionType.accessWifi,
    );
  }

  /// Requests contacts permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestContactsPermission();
  /// print('Contacts Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestContactsPermission() async {
    return _handlePermissionRequest(
      'requestContactsPermission',
      PermissionType.contacts,
    );
  }

  /// Requests SMS permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestSmsPermission();
  /// print('SMS Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestSmsPermission() async {
    return _handlePermissionRequest('requestSmsPermission', PermissionType.sms);
  }

  /// Requests notification permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestNotificationPermission();
  /// print('Notification Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestNotificationPermission() async {
    return _handlePermissionRequest(
      'requestNotificationPermission',
      PermissionType.notifications,
    );
  }

  /// Requests alarm permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestAlarmPermission();
  /// print('Alarm Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestAlarmPermission() async {
    return _handlePermissionRequest(
      'requestAlarmPermission',
      PermissionType.alarm,
    );
  }

  /// Requests microphone permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestMicrophonePermission();
  /// print('Microphone Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestMicrophonePermission() async {
    return _handlePermissionRequest(
      'requestMicrophonePermission',
      PermissionType.microphone,
    );
  }

  /// Requests calendar permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestCalendarPermission();
  /// print('Calendar Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestCalendarPermission() async {
    return _handlePermissionRequest(
      'requestCalendarPermission',
      PermissionType.calendar,
    );
  }

  /// Requests phone permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestPhonePermission();
  /// print('Phone Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestPhonePermission() async {
    return _handlePermissionRequest(
      'requestPhonePermission',
      PermissionType.phone,
    );
  }

  /// Requests activity recognition permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestActivityRecognitionPermission();
  /// print('Activity Recognition Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestActivityRecognitionPermission() async {
    return _handlePermissionRequest(
      'requestActivityRecognitionPermission',
      PermissionType.activityRecognition,
    );
  }

  /// Requests nearby devices permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestNearbyDevicesPermission();
  /// print('Nearby Devices Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestNearbyDevicesPermission() async {
    return _handlePermissionRequest(
      'requestNearbyDevicesPermission',
      PermissionType.nearbyDevices,
    );
  }

  /// Checks the status of a specific permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.checkPermissionStatus(PermissionType.camera.value);
  /// print('Camera Permission Status: \$status');
  /// ```

  Future<PermissionStatus> checkPermissionStatus(String permission) async {
    final status = await PermissionMasterPlatform.instance
        .checkPermissionStatus(permission);
    return _mapStatus(status);
  }

  /// Checks the status of multiple permissions.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final statuses = await permissionMaster.checkMultiplePermissions([PermissionType.camera, PermissionType.location]);
  /// print('Permission Statuses: \$statuses');
  /// ```

  Future<Map<String, PermissionStatus>> checkMultiplePermissions(
    List<PermissionType> permissions,
  ) async {
    final result = await PermissionMasterPlatform.instance
        .checkMultiplePermissions(permissions.map((p) => p.value).toList());
    return result.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  /// Opens the app settings to allow the user to manually enable permissions.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openAppSettings();
  /// ```

  Future<void> openAppSettings() {
    return PermissionMasterPlatform.instance.openAppSettings();
  }

  /// Handles the permission request and shows a dialog if necessary.
  Future<PermissionStatus> _handlePermissionRequest(
    String method,
    PermissionType permission,
  ) async {
    final status = await PermissionMasterPlatform.instance.requestPermission(
      method,
    );
    if (status == 'OPEN_SETTINGS') {
      final shouldOpenSettings = await _showSettingsDialog(permission);
      if (shouldOpenSettings) {
        await openAppSettings();
        return checkPermissionStatus(permission.value);
      }
    }
    return _mapStatus(status);
  }

  /// Maps the string status returned by the platform to the PermissionStatus enum.
  PermissionStatus _mapStatus(String status) {
    switch (status) {
      case 'GRANTED':
        return PermissionStatus.granted;
      case 'DENIED':
        return PermissionStatus.denied;
      case 'OPEN_SETTINGS':
        return PermissionStatus.openSettings;
      case 'NOT_SUPPORTED':
        return PermissionStatus.unsupported;
      case 'ERROR':
      default:
        return PermissionStatus.error;
    }
  }

  /// Shows a dialog to the user to open app settings.
  Future<bool> _showSettingsDialog(PermissionType permission) async {
    final context = MethodChannelPermissionMaster.context;
    if (context == null) return false;

    return await showDialog<bool>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                title: const Text('Permission Required'),
                content: Text(
                  'Please enable ${permission.name} permission from ${Platform.isAndroid ? "app settings" : "Settings"}.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Settings'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Requests a specific permission and automatically opens app settings if the permission is permanently denied.
  /// This method is useful when you want to handle permanent denials by redirecting the user to app settings.
  ///
  /// [permission]: The type of permission to request.
  /// Returns: The status of the permission request (PermissionStatus).
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.grantedRequestPermission(PermissionType.camera);
  /// if (status == PermissionStatus.granted) {
  ///   print('Camera permission granted!');
  /// } else {
  ///   print('Permission denied or needs manual settings adjustment.');
  /// }
  /// ```

  Future<void> grantedRequestPermission({
    required PermissionType permission,
  }) async {
    final context = MethodChannelPermissionMaster.context;
    if (context == null) return;

    final shouldRequestPermission = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allow ${permission.name} Permission'),
          content: Text(
            'Please enable ${permission.name} permission from ${Platform.isAndroid ? "app settings" : "Settings"}.',
          ),
          actions: [
            TextButton(
              child: const Text('Deny'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Allow'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldRequestPermission == true) {
      final status = await requestPermission(permission: permission);
      if (status == PermissionStatus.openSettings) {
        await openAppSettingsDirectly();
      }
    } else {
      // Handle permission denial
      denyRequestPermission(permission: permission);
    }
  }

  /// Opens the app settings directly without showing any dialog.
  /// This is useful when you want to redirect the user to settings without additional prompts.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openAppSettingsDirectly();
  /// print('App settings opened.');
  /// ```

  Future<void> openAppSettingsDirectly() {
    return PermissionMasterPlatform.instance.openAppSettings();
  }

  /// Explicitly denies a permission and stores the denial status, time, and count in local storage.
  /// This method is useful for tracking user behavior and avoiding repeated permission requests.
  ///
  /// [permission]: The type of permission being denied.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.denyRequestPermission(PermissionType.location);
  /// print('Location permission denied and stored.');
  /// ```

  Future<void> denyRequestPermission({
    required PermissionType permission,
  }) async {
    final storage = GetStorageBridge();

    // Store the permission denial status
    await storage.write('permission_${permission.value}_status', 'DENIED');

    // Store the timestamp of the denial
    await storage.write(
      'permission_${permission.value}_denied_time',
      DateTime.now().millisecondsSinceEpoch,
    );

    // Increment the denial count
    int denyCount = await storage.read(
      'permission_${permission.value}_deny_count',
      0,
    );
    await storage.write(
      'permission_${permission.value}_deny_count',
      denyCount + 1,
    );

    // Log the denial
    debugPrint(
      'Permission ${permission.name} has been explicitly denied and stored',
    );
  }
}
