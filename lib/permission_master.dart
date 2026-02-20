// ignore_for_file: unreachable_switch_default, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

import 'permission_master_method_channel.dart';
import 'permission_master_platform_interface.dart';

export 'package:permission_master/src/get_storage_bridge.dart';
export 'package:permission_master/src/permission_status.dart';
export 'package:permission_master/src/permission_type.dart';

/// A class to manage and request permissions in a Flutter application.
///
/// This class provides methods to request various permissions on both Android and iOS platforms.
/// Permissions are requested in normal state (not granted by default) and require user interaction.
///
/// Example usage:
///
/// ```dart
/// class _MyAppState extends State<MyApp> {
///   @override
///   void initState() {
///     super.initState();
///     PermissionMaster.setContext(context);
///   }
///
///   Future<void> _requestCameraPermission() async {
///     final permissionMaster = PermissionMaster();
///
///     // Check current permission status first
///     final currentStatus = await permissionMaster.checkPermissionStatus(PermissionType.camera.value);
///
///     if (currentStatus == PermissionStatus.granted) {
///       print('Camera permission already granted');
///       return;
///     }
///
///     // Request camera permission
///     final status = await permissionMaster.requestCameraPermission();
///
///     switch (status) {
///       case PermissionStatus.granted:
///         print('Camera permission granted - can now use camera');
///         break;
///       case PermissionStatus.denied:
///         print('Camera permission denied by user');
///         break;
///       case PermissionStatus.openSettings:
///         print('Camera permission permanently denied - opening settings');
///         await permissionMaster.openAppSettings();
///         break;
///       default:
///         print('Error requesting camera permission');
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         appBar: AppBar(title: Text('Permission Master Example')),
///         body: Center(
///           child: ElevatedButton(
///             onPressed: _requestCameraPermission,
///             child: Text('Request Camera Permission'),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```

class PermissionMaster {
  /// Platform interface instance
  final PermissionMasterPlatform _permissionMasterPlatform =
      PermissionMasterPlatform.instance;

  /// Sets the context for the permission master.
  static void setContext(BuildContext context) {
    PermissionMasterPlatform.setGlobalContext(context);
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
      case PermissionType.health:
        return requestHealthPermission();
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
  ///
  ///
  /// ```

  Future<PermissionStatus> requestCameraPermission() async {
    return _handlePermissionRequest(
      'requestCameraPermission',
      PermissionType.camera,
    );
  }

  /// Requests camera permission for web platform.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final result = await permissionMaster.requestCameraPermissionWeb();
  /// print('Web Camera Permission Result: \$result');
  /// ```

  Future<PermissionStatus> requestCameraPermissionWeb() async {
    final result = await _permissionMasterPlatform.requestPermission(
      'requestCameraPermission',
    );
    return _mapStatus(result);
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

  /// Requests location permission for web platform.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final result = await permissionMaster.requestLocationPermissionWeb();
  /// print('Web Location Permission Result: \$result');
  /// ```

  Future<PermissionStatus> requestLocationPermissionWeb() async {
    final result = await _permissionMasterPlatform.requestPermission(
      'requestLocationPermission',
    );
    return _mapStatus(result);
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

  /// Requests notification permission for web platform.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final result = await permissionMaster.requestNotificationPermissionWeb();
  /// print('Web Notification Permission Result: \$result');
  /// ```

  Future<PermissionStatus> requestNotificationPermissionWeb() async {
    final result = await _permissionMasterPlatform.requestPermission(
      'requestNotificationPermission',
    );
    return _mapStatus(result);
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

  /// Requests microphone permission for web platform.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final result = await permissionMaster.requestMicrophonePermissionWeb();
  /// print('Web Microphone Permission Result: \$result');
  /// ```

  Future<PermissionStatus> requestMicrophonePermissionWeb() async {
    final result = await _permissionMasterPlatform.requestPermission(
      'requestMicrophonePermission',
    );
    return _mapStatus(result);
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

  /// Requests health permission.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestHealthPermission();
  /// print('Health Permission Status: \$status');
  /// ```

  Future<PermissionStatus> requestHealthPermission() async {
    return _handlePermissionRequest(
      'requestHealthPermission',
      PermissionType.health,
    );
  }

  /// Requests photos/storage permission (iOS specific naming)
  /// Alias for requestStoragePermission
  Future<PermissionStatus> requestPhotosPermission() async {
    return requestStoragePermission();
  }

  /// Requests reminders permission (iOS specific)
  Future<PermissionStatus> requestRemindersPermission() async {
    return _handlePermissionRequest(
      'requestRemindersPermission',
      PermissionType.calendar, // Using calendar type as fallback
    );
  }

  /// Requests motion & fitness permission (iOS specific)
  Future<PermissionStatus> requestMotionPermission() async {
    return requestActivityRecognitionPermission();
  }

  /// Requests speech recognition permission (iOS specific)
  Future<PermissionStatus> requestSpeechPermission() async {
    return _handlePermissionRequest(
      'requestSpeechRecognitionPermission',
      PermissionType.microphone, // Using microphone as fallback
    );
  }

  /// Requests music/media library permission (iOS specific)
  Future<PermissionStatus> requestMusicPermission() async {
    return _handlePermissionRequest(
      'requestMusicLibraryPermission',
      PermissionType.readStorage, // Using storage as fallback
    );
  }

  /// Gets the storage bridge instance for custom data persistence
  GetStorageBridge get storage => GetStorageBridge();

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
  ///
  ///
  /// ```

  Future<Map<String, PermissionStatus>> checkMultiplePermissions(
    List<PermissionType> permissions,
  ) async {
    final result = await PermissionMasterPlatform.instance
        .checkMultiplePermissions(permissions.map((p) => p.value).toList());
    return result.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  /// Opens the app settings to allow the user to manually enable permissions.
  /// Returns true if settings were opened successfully, false otherwise.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final opened = await permissionMaster.openAppSettings();
  /// print('Settings opened: $opened');
  /// ```

  Future<bool> openAppSettings() async {
    try {
      await PermissionMasterPlatform.instance.openAppSettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Opens camera settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openCameraSettings();
  /// ```
  Future<void> openCameraSettings() {
    return PermissionMasterPlatform.instance.openCameraSettings();
  }

  /// Opens microphone settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openMicrophoneSettings();
  /// ```
  Future<void> openMicrophoneSettings() {
    return PermissionMasterPlatform.instance.openMicrophoneSettings();
  }

  /// Opens location settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openLocationSettings();
  /// ```
  Future<void> openLocationSettings() {
    return PermissionMasterPlatform.instance.openLocationSettings();
  }

  /// Opens notification settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openNotificationSettings();
  /// ```
  Future<void> openNotificationSettings() {
    return PermissionMasterPlatform.instance.openNotificationSettings();
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
    switch (status.toUpperCase()) {
      case 'GRANTED':
        return PermissionStatus.granted;
      case 'DENIED':
        return PermissionStatus.denied;
      case 'OPEN_SETTINGS':
      case 'OPENSETTINGS':
        return PermissionStatus.openSettings;
      case 'NOT_SUPPORTED':
      case 'UNSUPPORTED':
        return PermissionStatus.unsupported;
      case 'RESTRICTED':
        return PermissionStatus.restricted;
      case 'LIMITED':
        return PermissionStatus.limited;
      case 'NOT_DETERMINED':
      case 'NOTDETERMINED':
        return PermissionStatus.notDetermined;
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
          builder: (BuildContext context) => AlertDialog(
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

  /// Requests a specific permission with a custom dialog.
  /// This method shows a dialog to the user before requesting the permission.
  ///
  /// [permission]: The type of permission to request.
  /// [title]: Custom title for the permission dialog (optional).
  /// [message]: Custom message for the permission dialog (optional).
  /// Returns: The status of the permission request (PermissionStatus).
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestPermissionWithDialog(
  ///   permission: PermissionType.camera,
  ///   title: 'Camera Access Required',
  ///   message: 'This app needs camera access to take photos.',
  /// );
  /// if (status == PermissionStatus.granted) {
  ///   print('Camera permission granted!');
  /// } else {
  ///   print('Permission denied or needs manual settings adjustment.');
  /// }
  /// ```

  Future<PermissionStatus> requestPermissionWithDialog({
    required PermissionType permission,
    String? title,
    String? message,
  }) async {
    // For Android, directly request the permission to show native system dialog
    // The title and message parameters are kept for API compatibility but not used
    // as Android's native permission dialogs have their own standard text
    if (Platform.isAndroid) {
      final status = await requestPermission(permission: permission);
      if (status == PermissionStatus.openSettings) {
        // Show a dialog explaining that the user needs to enable permission in settings
        final context = MethodChannelPermissionMaster.context;
        if (context != null) {
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title ?? '${permission.name} Permission Required'),
                content: Text(
                  message ??
                      'Please enable ${permission.name} permission in app settings to use this feature.',
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
              );
            },
          );

          if (shouldOpenSettings == true) {
            await openAppSettingsDirectly();
            return await checkPermissionStatus(permission.value);
          }
        }
      }
      return status;
    }

    // For other platforms (iOS, macOS, etc.), keep the original behavior
    // as they might need custom dialogs
    final context = MethodChannelPermissionMaster.context;
    if (context == null) {
      // If no context, request permission directly
      return await requestPermission(permission: permission);
    }

    final shouldRequestPermission = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Allow ${permission.name} Permission'),
          content: Text(
            message ??
                'This app needs ${permission.name} permission to function properly.',
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
        return await checkPermissionStatus(permission.value);
      }
      return status;
    } else {
      // Handle permission denial
      await denyRequestPermission(permission: permission);
      return PermissionStatus.denied;
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

    // Permission has been explicitly denied and stored
  }

  // Windows specific methods
  /// Requests camera permission on Windows.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestCameraPermissionWindows();
  /// print('Windows Camera Permission Status: \$status');
  /// ```
  Future<String> requestCameraPermissionWindows() async {
    return await _permissionMasterPlatform.requestCameraPermissionWindows();
  }

  /// Requests microphone permission on Windows.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestMicrophonePermissionWindows();
  /// print('Windows Microphone Permission Status: \$status');
  /// ```
  Future<String> requestMicrophonePermissionWindows() async {
    return await _permissionMasterPlatform.requestMicrophonePermissionWindows();
  }

  // macOS specific permission methods
  /// Requests camera permission on macOS.
  Future<String> requestCameraPermissionMac() async {
    return await _permissionMasterPlatform.requestCameraPermissionMac();
  }

  /// Requests microphone permission on macOS.
  Future<String> requestMicrophonePermissionMac() async {
    return await _permissionMasterPlatform.requestMicrophonePermissionMac();
  }

  /// Requests location permission on macOS.
  Future<String> requestLocationPermissionMac() async {
    return await _permissionMasterPlatform.requestLocationPermissionMac();
  }

  /// Requests photo library permission on macOS.
  Future<String> requestPhotoLibraryPermissionMac() async {
    return await _permissionMasterPlatform.requestPhotoLibraryPermissionMac();
  }

  /// Requests contacts permission on macOS.
  Future<String> requestContactsPermissionMac() async {
    return await _permissionMasterPlatform.requestContactsPermissionMac();
  }

  /// Requests notification permission on macOS.
  Future<String> requestNotificationPermissionMac() async {
    return await _permissionMasterPlatform.requestNotificationPermissionMac();
  }

  /// Requests Bluetooth permission on macOS.
  Future<String> requestBluetoothPermissionMac() async {
    return await _permissionMasterPlatform.requestBluetoothPermissionMac();
  }

  /// Requests calendar permission on macOS.
  Future<String> requestCalendarPermissionMac() async {
    return await _permissionMasterPlatform.requestCalendarPermissionMac();
  }

  /// Requests reminders permission on macOS.
  Future<String> requestRemindersPermissionMac() async {
    return await _permissionMasterPlatform.requestRemindersPermissionMac();
  }

  /// Requests speech recognition permission on macOS.
  Future<String> requestSpeechRecognitionPermissionMac() async {
    return await _permissionMasterPlatform
        .requestSpeechRecognitionPermissionMac();
  }

  /// Checks camera permission status on macOS.
  Future<String> checkCameraPermissionMac() async {
    return await _permissionMasterPlatform.checkCameraPermissionMac();
  }

  /// Checks microphone permission status on macOS.
  Future<String> checkMicrophonePermissionMac() async {
    return await _permissionMasterPlatform.checkMicrophonePermissionMac();
  }

  /// Checks location permission status on macOS.
  Future<String> checkLocationPermissionMac() async {
    return await _permissionMasterPlatform.checkLocationPermissionMac();
  }

  /// Checks photo library permission status on macOS.
  Future<String> checkPhotoLibraryPermissionMac() async {
    return await _permissionMasterPlatform.checkPhotoLibraryPermissionMac();
  }

  /// Checks contacts permission status on macOS.
  Future<String> checkContactsPermissionMac() async {
    return await _permissionMasterPlatform.checkContactsPermissionMac();
  }

  /// Checks notification permission status on macOS.
  Future<String> checkNotificationPermissionMac() async {
    return await _permissionMasterPlatform.checkNotificationPermissionMac();
  }

  /// Checks Bluetooth permission status on macOS.
  Future<String> checkBluetoothPermissionMac() async {
    return await _permissionMasterPlatform.checkBluetoothPermissionMac();
  }

  /// Checks calendar permission status on macOS.
  Future<String> checkCalendarPermissionMac() async {
    return await _permissionMasterPlatform.checkCalendarPermissionMac();
  }

  /// Checks reminders permission status on macOS.
  Future<String> checkRemindersPermissionMac() async {
    return await _permissionMasterPlatform.checkRemindersPermissionMac();
  }

  /// Checks speech recognition permission status on macOS.
  Future<String> checkSpeechRecognitionPermissionMac() async {
    return await _permissionMasterPlatform
        .checkSpeechRecognitionPermissionMac();
  }

  /// Opens macOS app settings.
  Future<void> openAppSettingsMac() async {
    await _permissionMasterPlatform.openAppSettingsMac();
  }

  /// Checks camera permission status on Windows.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.checkCameraPermissionWindows();
  /// print('Windows Camera Permission Status: \$status');
  /// ```
  Future<String> checkCameraPermissionWindows() async {
    return await _permissionMasterPlatform.checkCameraPermissionWindows();
  }

  /// Checks microphone permission status on Windows.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.checkMicrophonePermissionWindows();
  /// print('Windows Microphone Permission Status: \$status');
  /// ```
  Future<String> checkMicrophonePermissionWindows() async {
    return await _permissionMasterPlatform.checkMicrophonePermissionWindows();
  }

  /// Checks permission status on Windows.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.checkPermissionStatusWindows('camera');
  /// print('Windows Permission Status: \$status');
  /// ```
  Future<String> checkPermissionStatusWindows(String permission) async {
    return await _permissionMasterPlatform.checkPermissionStatusWindows(
      permission,
    );
  }

  /// Opens Windows app settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openAppSettingsWindows();
  /// ```
  Future<void> openAppSettingsWindows() async {
    await _permissionMasterPlatform.openAppSettingsWindows();
  }

  /// Opens Windows camera settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openCameraSettingsWindows();
  /// ```
  Future<void> openCameraSettingsWindows() async {
    await _permissionMasterPlatform.openCameraSettingsWindows();
  }

  /// Opens Windows microphone settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openMicrophoneSettingsWindows();
  /// ```
  Future<void> openMicrophoneSettingsWindows() async {
    await _permissionMasterPlatform.openMicrophoneSettingsWindows();
  }

  // Additional Windows permission methods
  /// Requests location permission on Windows.
  Future<String> requestLocationPermissionWindows() async {
    return await _permissionMasterPlatform.requestLocationPermissionWindows();
  }

  /// Checks location permission status on Windows.
  Future<String> checkLocationPermissionWindows() async {
    return await _permissionMasterPlatform.checkLocationPermissionWindows();
  }

  /// Requests notification permission on Windows.
  Future<String> requestNotificationPermissionWindows() async {
    return await _permissionMasterPlatform
        .requestNotificationPermissionWindows();
  }

  /// Checks notification permission status on Windows.
  Future<String> checkNotificationPermissionWindows() async {
    return await _permissionMasterPlatform.checkNotificationPermissionWindows();
  }

  /// Requests radios permission on Windows.
  Future<String> requestRadiosPermissionWindows() async {
    return await _permissionMasterPlatform.requestRadiosPermissionWindows();
  }

  /// Checks radios permission status on Windows.
  Future<String> checkRadiosPermissionWindows() async {
    return await _permissionMasterPlatform.checkRadiosPermissionWindows();
  }

  /// Requests voice activation permission on Windows.
  Future<String> requestVoiceActivationPermissionWindows() async {
    return await _permissionMasterPlatform
        .requestVoiceActivationPermissionWindows();
  }

  /// Checks voice activation permission status on Windows.
  Future<String> checkVoiceActivationPermissionWindows() async {
    return await _permissionMasterPlatform
        .checkVoiceActivationPermissionWindows();
  }

  /// Requests email permission on Windows.
  Future<String> requestEmailPermissionWindows() async {
    return await _permissionMasterPlatform.requestEmailPermissionWindows();
  }

  /// Checks email permission status on Windows.
  Future<String> checkEmailPermissionWindows() async {
    return await _permissionMasterPlatform.checkEmailPermissionWindows();
  }

  /// Opens Windows location settings.
  Future<void> openLocationSettingsWindows() async {
    await _permissionMasterPlatform.openLocationSettingsWindows();
  }

  /// Opens Windows notification settings.
  Future<void> openNotificationSettingsWindows() async {
    await _permissionMasterPlatform.openNotificationSettingsWindows();
  }

  /// Opens Windows radios settings.
  Future<void> openRadiosSettingsWindows() async {
    await _permissionMasterPlatform.openRadiosSettingsWindows();
  }

  /// Opens Windows speech settings.
  Future<void> openSpeechSettingsWindows() async {
    await _permissionMasterPlatform.openSpeechSettingsWindows();
  }

  // Linux specific methods
  /// Requests camera permission on Linux.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestCameraPermissionLinux();
  /// print('Linux Camera Permission Status: \$status');
  /// ```
  Future<String> requestCameraPermissionLinux() async {
    return await _permissionMasterPlatform.requestCameraPermissionLinux();
  }

  /// Requests microphone permission on Linux.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// final status = await permissionMaster.requestMicrophonePermissionLinux();
  /// print('Linux Microphone Permission Status: \$status');
  /// ```
  Future<String> requestMicrophonePermissionLinux() async {
    return await _permissionMasterPlatform.requestMicrophonePermissionLinux();
  }

  /// Requests location permission on Linux.
  Future<String> requestLocationPermissionLinux() async {
    return await _permissionMasterPlatform.requestLocationPermissionLinux();
  }

  /// Requests storage permission on Linux.
  Future<String> requestStoragePermissionLinux() async {
    return await _permissionMasterPlatform.requestStoragePermissionLinux();
  }

  /// Requests contacts permission on Linux.
  Future<String> requestContactsPermissionLinux() async {
    return await _permissionMasterPlatform.requestContactsPermissionLinux();
  }

  /// Requests calendar permission on Linux.
  Future<String> requestCalendarPermissionLinux() async {
    return await _permissionMasterPlatform.requestCalendarPermissionLinux();
  }

  /// Requests notification permission on Linux.
  Future<String> requestNotificationPermissionLinux() async {
    return await _permissionMasterPlatform.requestNotificationPermissionLinux();
  }

  /// Requests Bluetooth permission on Linux.
  Future<String> requestBluetoothPermissionLinux() async {
    return await _permissionMasterPlatform.requestBluetoothPermissionLinux();
  }

  /// Requests network permission on Linux.
  Future<String> requestNetworkPermissionLinux() async {
    return await _permissionMasterPlatform.requestNetworkPermissionLinux();
  }

  /// Requests USB permission on Linux.
  Future<String> requestUsbPermissionLinux() async {
    return await _permissionMasterPlatform.requestUsbPermissionLinux();
  }

  /// Opens Linux app settings.
  /// Example usage:
  ///
  /// ```dart
  /// final permissionMaster = PermissionMaster();
  /// await permissionMaster.openAppSettingsLinux();
  /// ```
  Future<void> openAppSettingsLinux() async {
    await _permissionMasterPlatform.openAppSettingsLinux();
  }
}
