// ignore_for_file: unnecessary_null_comparison, unused_local_variable, override_on_non_overriding_member, invalid_runtime_check_with_js_interop_types, unrelated_type_equality_checks

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'permission_master_platform_interface.dart';

/// A web implementation of the PermissionMasterPlatform of the PermissionMaster plugin.
class PermissionMasterWeb extends PermissionMasterPlatform {
  /// Constructs a PermissionMasterWeb
  PermissionMasterWeb();

  static void registerWith(Registrar registrar) {
    PermissionMasterPlatform.instance = PermissionMasterWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  // Enhanced debugging method to check browser capabilities
  Future<Map<String, dynamic>> checkBrowserCapabilities() async {
    final capabilities = <String, dynamic>{};

    // Check protocol and hostname
    capabilities['protocol'] = web.window.location.protocol;
    capabilities['hostname'] = web.window.location.hostname;
    capabilities['isHttps'] = web.window.location.protocol.startsWith('https');
    capabilities['isLocalhost'] = web.window.location.hostname == 'localhost';

    // Check media devices
    capabilities['mediaDevices'] = web.window.navigator.mediaDevices != null;
    capabilities['getUserMedia'] = web.window.navigator.mediaDevices != null;

    // Check geolocation
    capabilities['geolocation'] = web.window.navigator.geolocation != null;
    capabilities['getCurrentPosition'] =
        web.window.navigator.geolocation != null;

    // Check notifications
    try {
      capabilities['notifications'] = web.Notification.permission != null;
      capabilities['notificationPermission'] = web.Notification.permission;
    } catch (e) {
      capabilities['notifications'] = false;
      capabilities['notificationError'] = e.toString();
    }

    // Check permissions API
    capabilities['permissionsAPI'] = web.window.navigator.permissions != null;

    // Check user agent for debugging
    capabilities['userAgent'] = web.window.navigator.userAgent;

    return capabilities;
  }

  @override
  void setContext(context) {
    // Context is not needed for web implementation
  }

  @override
  Future<String> requestPermission(String method) async {
    switch (method) {
      case 'requestCameraPermission':
        return await requestCameraPermissionWeb();
      case 'requestMicrophonePermission':
        return await requestMicrophonePermissionWeb();
      case 'requestLocationPermission':
        return await requestLocationPermissionWeb();
      case 'requestNotificationPermission':
        return await requestNotificationPermissionWeb();
      default:
        return 'unsupported';
    }
  }

  // Camera Permission Methods
  Future<String> requestCameraPermissionWeb() async {
    try {
      // Check if running on HTTPS (required for camera permissions)
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Camera permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!protocol.startsWith('https') && hostname != 'localhost') {
        debugPrint(
          'Camera permission requires HTTPS context - Current: $protocol://$hostname',
        );
        return 'denied';
      }

      final mediaDevices = web.window.navigator.mediaDevices;
      debugPrint('Media devices: $mediaDevices');
      if (mediaDevices == null) {
        debugPrint('Media devices not supported');
        return 'unsupported';
      }

      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );

      final stream = await mediaDevices.getUserMedia(constraints).toDart;

      // Stop the stream immediately as we only wanted to check permission
      final tracks = stream.getTracks();
      for (int i = 0; i < tracks.length; i++) {
        tracks[i].stop();
      }
      return 'granted';
    } catch (e) {
      debugPrint('Camera permission error: $e');
      if (e is web.DOMException) {
        final errorName = e.name;
        if (errorName == 'NotAllowedError') {
          return 'denied';
        } else if (errorName == 'NotFoundError') {
          return 'unsupported';
        } else if (errorName == 'PermissionDeniedError') {
          return 'denied';
        }
      }
      return 'error';
    }
  }

  @override
  Future<String> requestCameraPermission() async {
    return requestCameraPermissionWeb();
  }

  Future<String> checkCameraPermission() async {
    return checkCameraPermissionWeb();
  }

  Future<String> checkCameraPermissionWeb() async {
    try {
      // Check if mediaDevices API is available
      final mediaDevices = web.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        return 'unsupported';
      }

      // Try to enumerate devices to check camera availability
      try {
        final devices = await mediaDevices.enumerateDevices().toDart;
        bool hasCamera = false;
        for (int i = 0; i < devices.length; i++) {
          final device = devices[i];
          if (device.kind == 'videoinput') {
            hasCamera = true;
            break;
          }
        }

        if (!hasCamera) {
          return 'unsupported';
        }
      } catch (e) {
        // If enumerateDevices fails, camera might still be available
        debugPrint('Error enumerating devices: $e');
      }

      // Try to check permission status using Permissions API if available
      if (web.window.navigator.permissions != null) {
        try {
          final permissions = web.window.navigator.permissions;
          final queryOptions = {'name': 'camera'}.jsify() as JSObject;
          final result = await permissions.query(queryOptions).toDart;
          if (result != null) {
            final state = result.state;
            switch (state) {
              case 'granted':
                return 'granted';
              case 'denied':
                return 'denied';
              case 'prompt':
                return 'denied'; // Not yet requested
              default:
                return 'denied';
            }
          }
        } catch (e) {
          debugPrint(
            'Error checking camera permission via Permissions API: $e',
          );
        }
      }

      // Default fallback
      return 'denied';
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return 'error';
    }
  }

  // Microphone Permission Methods
  Future<String> requestMicrophonePermissionWeb() async {
    try {
      // Check if running on HTTPS (required for microphone permissions)
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Microphone permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!protocol.startsWith('https') && hostname != 'localhost') {
        debugPrint(
          'Microphone permission requires HTTPS context - Current: $protocol://$hostname',
        );
        return 'denied';
      }

      final mediaDevices = web.window.navigator.mediaDevices;
      debugPrint('Media devices: $mediaDevices');
      if (mediaDevices == null) {
        debugPrint('Media devices not supported');
        return 'unsupported';
      }

      final constraints = web.MediaStreamConstraints(
        audio: true.toJS,
        video: false.toJS,
      );

      final stream = await mediaDevices.getUserMedia(constraints).toDart;

      // Stop the stream immediately as we only wanted to check permission
      final tracks = stream.getTracks();
      for (int i = 0; i < tracks.length; i++) {
        tracks[i].stop();
      }
      return 'granted';
    } catch (e) {
      debugPrint('Microphone permission error: $e');
      if (e is web.DOMException) {
        final errorName = e.name;
        if (errorName == 'NotAllowedError') {
          return 'denied';
        } else if (errorName == 'NotFoundError') {
          return 'unsupported';
        } else if (errorName == 'PermissionDeniedError') {
          return 'denied';
        }
      }
      return 'error';
    }
  }

  @override
  Future<String> requestMicrophonePermission() async {
    return requestMicrophonePermissionWeb();
  }

  Future<String> checkMicrophonePermission() async {
    return checkMicrophonePermissionWeb();
  }

  Future<String> checkMicrophonePermissionWeb() async {
    try {
      // Check if mediaDevices API is available
      final mediaDevices = web.window.navigator.mediaDevices;

      // Try to enumerate devices to check microphone availability
      final devices = await mediaDevices.enumerateDevices().toDart;
      bool hasMicrophone = false;
      for (int i = 0; i < devices.length; i++) {
        final device = devices[i];
        if (device.kind == 'audioinput') {
          hasMicrophone = true;
          break;
        }
      }

      if (!hasMicrophone) {
        return 'unsupported';
      }

      // For web, we return 'denied' as default state since we can't check
      // permission status without requesting it first
      return 'denied';
    } catch (e) {
      return 'error';
    }
  }

  // Location Permission Methods
  Future<String> requestLocationPermissionWeb() async {
    try {
      // Check if running on HTTPS (required for geolocation)
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Location permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!protocol.startsWith('https') && hostname != 'localhost') {
        debugPrint(
          'Location permission requires HTTPS context - Current: $protocol://$hostname',
        );
        return 'denied';
      }

      final geolocation = web.window.navigator.geolocation;
      debugPrint('Geolocation: $geolocation');
      if (geolocation == null) {
        debugPrint('Geolocation not supported');
        return 'unsupported';
      }

      final completer = Completer<String>();

      final options = web.PositionOptions(
        enableHighAccuracy: false,
        timeout: 5000,
        maximumAge: 0,
      );

      geolocation.getCurrentPosition(
        (web.GeolocationPosition position) {
          completer.complete('granted');
        }.toJS,
        (web.GeolocationPositionError error) {
          debugPrint('Location error: ${error.code} - ${error.message}');
          if (error.code == 1) {
            // PERMISSION_DENIED
            completer.complete('denied');
          } else if (error.code == 2) {
            // POSITION_UNAVAILABLE
            completer.complete('denied');
          } else if (error.code == 3) {
            // TIMEOUT
            completer.complete('denied');
          } else {
            completer.complete('unsupported');
          }
        }.toJS,
        options,
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return 'error';
    }
  }

  @override
  Future<String> requestLocationPermission() async {
    return requestLocationPermissionWeb();
  }

  Future<String> checkLocationPermission() async {
    return checkLocationPermissionWeb();
  }

  Future<String> checkLocationPermissionWeb() async {
    try {
      // Check if geolocation API is available
      final geolocation = web.window.navigator.geolocation;

      // For web, we return 'denied' as default state since we can't check
      // permission status without requesting it first
      return 'denied';
    } catch (e) {
      return 'error';
    }
  }

  // Notification Permission Methods
  Future<String> requestNotificationPermissionWeb() async {
    try {
      // Check if notifications are supported
      debugPrint('Checking notification support...');
      try {
        final permission = web.Notification.permission;
        debugPrint('Notification permission API available: $permission');
      } catch (e) {
        debugPrint('Notifications not supported: $e');
        return 'unsupported';
      }

      if (web.window.navigator.permissions != null) {
        final permissions = web.window.navigator.permissions;
        final queryOptions = {'name': 'notifications'}.jsify() as JSObject;
        final result = await permissions.query(queryOptions).toDart;

        if (result != null) {
          final state = result.state;
          if (state == 'granted') {
            return 'granted';
          } else if (state == 'denied') {
            return 'denied';
          } else if (state == 'prompt') {
            // Request permission
            final permission =
                await web.Notification.requestPermission().toDart;
            return permission == 'granted' ? 'granted' : 'denied';
          }
        }
      } else {
        // Fallback for browsers that don't support permissions API
        final permission = await web.Notification.requestPermission().toDart;
        return permission == 'granted' ? 'granted' : 'denied';
      }

      return 'denied';
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return 'error';
    }
  }

  @override
  Future<String> requestNotificationPermission() async {
    return requestNotificationPermissionWeb();
  }

  Future<String> checkNotificationPermission() async {
    return checkNotificationPermissionWeb();
  }

  Future<String> checkNotificationPermissionWeb() async {
    try {
      // Check if Notification API is supported
      try {
        web.Notification.permission;
      } catch (e) {
        return 'unsupported';
      }

      final permission = web.Notification.permission;
      switch (permission) {
        case 'granted':
          return 'granted';
        case 'denied':
          return 'denied';
        case 'default':
        default:
          return 'denied';
      }
    } catch (e) {
      return 'error';
    }
  }

  // Web-specific permissions that are not applicable
  @override
  Future<String> requestRadiosPermission() async {
    // Radios permission is not applicable for web
    return 'unsupported';
  }

  @override
  Future<String> checkRadiosPermission() async {
    // Radios permission is not applicable for web
    return 'unsupported';
  }

  @override
  Future<String> requestVoiceActivationPermission() async {
    // Voice activation is handled through microphone permission in web
    return requestMicrophonePermissionWeb();
  }

  @override
  Future<String> checkVoiceActivationPermission() async {
    // Voice activation is handled through microphone permission in web
    return checkMicrophonePermissionWeb();
  }

  @override
  Future<String> requestEmailPermission() async {
    // Email permission is not applicable for web
    return 'unsupported';
  }

  @override
  Future<String> checkEmailPermission() async {
    // Email permission is not applicable for web
    return 'unsupported';
  }

  // Settings methods - Web browsers handle settings through browser UI
  @override
  Future<void> openCameraSettings() async {
    // Web browsers don't have direct camera settings access
    // Users need to manage permissions through browser settings
    _showBrowserSettingsMessage('Camera');
  }

  @override
  Future<void> openMicrophoneSettings() async {
    // Web browsers don't have direct microphone settings access
    _showBrowserSettingsMessage('Microphone');
  }

  @override
  Future<void> openLocationSettings() async {
    // Web browsers don't have direct location settings access
    _showBrowserSettingsMessage('Location');
  }

  @override
  Future<void> openNotificationSettings() async {
    // Web browsers don't have direct notification settings access
    _showBrowserSettingsMessage('Notification');
  }

  @override
  Future<void> openRadiosSettings() async {
    // Not applicable for web
    _showNotApplicableMessage('Radios');
  }

  @override
  Future<void> openVoiceActivationSettings() async {
    // Voice activation settings are handled through microphone settings
    openMicrophoneSettings();
  }

  @override
  Future<void> openEmailSettings() async {
    // Not applicable for web
    _showNotApplicableMessage('Email');
  }

  // Helper methods
  void _showBrowserSettingsMessage(String permissionType) {
    web.window.alert(
      '$permissionType permission can be managed through your browser settings.\n'
      'Look for the lock icon in the address bar or check browser settings > Privacy & Security > Site Settings.',
    );
  }

  void _showNotApplicableMessage(String permissionType) {
    web.window.alert(
      '$permissionType permission is not applicable for web applications.',
    );
  }

  // Windows-specific methods (not applicable for web)
  @override
  Future<String> requestCameraPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkCameraPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestMicrophonePermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkMicrophonePermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestLocationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkLocationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestNotificationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkNotificationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestRadiosPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkRadiosPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestVoiceActivationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkVoiceActivationPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> requestEmailPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<String> checkEmailPermissionWindows() async {
    return 'unsupported';
  }

  @override
  Future<void> openCameraSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openMicrophoneSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openLocationSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openNotificationSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openRadiosSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openVoiceActivationSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openEmailSettingsWindows() async {
    // Not applicable for web
  }

  // Additional permission methods that return unsupported for web
  @override
  Future<String> requestStoragePermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestBluetoothPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestSensorsPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestWifiPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestContactsPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestSmsPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestAlarmPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestCalendarPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestPhonePermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestActivityRecognitionPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> requestNearbyDevicesPermission() async {
    return 'unsupported';
  }

  @override
  Future<String> checkPermissionStatus(String permission) async {
    switch (permission) {
      case 'android.permission.CAMERA':
        return await checkCameraPermissionWeb();
      case 'android.permission.RECORD_AUDIO':
        return await checkMicrophonePermissionWeb();
      case 'android.permission.ACCESS_FINE_LOCATION':
        return await checkLocationPermissionWeb();
      case 'android.permission.POST_NOTIFICATIONS':
        return await checkNotificationPermissionWeb();
      default:
        return 'unsupported';
    }
  }

  @override
  Future<Map<String, String>> checkMultiplePermissions(
    List<String> permissions,
  ) async {
    Map<String, String> results = {};
    for (String permission in permissions) {
      results[permission] = await checkPermissionStatus(permission);
    }
    return results;
  }

  @override
  Future<String> checkPermissionStatusWindows(String permission) async {
    return 'unsupported';
  }

  @override
  Future<void> openAppSettings() async {
    _showBrowserSettingsMessage('App');
  }

  @override
  Future<void> openAppSettingsWindows() async {
    // Not applicable for web
  }

  @override
  Future<void> openSpeechSettingsWindows() async {
    // Not applicable for web
  }

  // macOS specific methods - not supported on web
  @override
  Future<String> requestCameraPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestMicrophonePermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestLocationPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestPhotoLibraryPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestContactsPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestNotificationPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestBluetoothPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestCalendarPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestRemindersPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> requestSpeechRecognitionPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkCameraPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkMicrophonePermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkLocationPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkPhotoLibraryPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkContactsPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkNotificationPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkBluetoothPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkCalendarPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkRemindersPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<String> checkSpeechRecognitionPermissionMac() async {
    return 'unsupported';
  }

  @override
  Future<void> openAppSettingsMac() async {
    // Not applicable for web
  }

  @override
  Future<void> openAppSettingsLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestBluetoothPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCalendarPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestCameraPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestContactsPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestLocationPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestMicrophonePermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNetworkPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestNotificationPermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestStoragePermissionLinux() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestUsbPermissionLinux() {
    throw UnimplementedError();
  }
}
