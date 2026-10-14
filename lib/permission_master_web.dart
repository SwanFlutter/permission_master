// ignore_for_file: invalid_runtime_check_with_js_interop_types

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
    capabilities['mediaDevices'] = true;
    capabilities['getUserMedia'] = true;

    // Check geolocation
    capabilities['geolocation'] = true;
    capabilities['getCurrentPosition'] = true;

    // Check notifications
    try {
      capabilities['notifications'] = true;
      capabilities['notificationPermission'] = web.Notification.permission;
    } catch (e) {
      capabilities['notifications'] = false;
      capabilities['notificationError'] = e.toString();
    }

    // Check permissions API
    capabilities['permissionsAPI'] = true;

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
      // Let the browser determine whether this origin is trustworthy.
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Camera permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!web.window.isSecureContext) {
        debugPrint(
          'Camera permission requires a secure context - Current: $protocol//$hostname',
        );
        return 'denied';
      }

      final mediaDevices = web.window.navigator.mediaDevices;
      debugPrint('Media devices: $mediaDevices');

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

  Future<String> checkCameraPermissionWeb() {
    return _queryBrowserPermission('camera');
  }

  // Microphone Permission Methods
  Future<String> requestMicrophonePermissionWeb() async {
    try {
      // Let the browser determine whether this origin is trustworthy.
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Microphone permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!web.window.isSecureContext) {
        debugPrint(
          'Microphone permission requires a secure context - Current: $protocol//$hostname',
        );
        return 'denied';
      }

      final mediaDevices = web.window.navigator.mediaDevices;
      debugPrint('Media devices: $mediaDevices');

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

  Future<String> checkMicrophonePermissionWeb() {
    return _queryBrowserPermission('microphone');
  }

  // Location Permission Methods
  Future<String> requestLocationPermissionWeb() async {
    try {
      // Let the browser determine whether this origin is trustworthy.
      final protocol = web.window.location.protocol;
      final hostname = web.window.location.hostname;
      debugPrint(
        'Location permission check - Protocol: $protocol, Hostname: $hostname',
      );

      if (!web.window.isSecureContext) {
        debugPrint(
          'Location permission requires a secure context - Current: $protocol//$hostname',
        );
        return 'denied';
      }

      final geolocation = web.window.navigator.geolocation;
      debugPrint('Geolocation: $geolocation');

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

  Future<String> checkLocationPermissionWeb() {
    return _queryBrowserPermission('geolocation');
  }

  // Querying does not request access. Device enumeration can hide devices until
  // access is granted, so it cannot establish permission or API support.
  Future<String> _queryBrowserPermission(String name) async {
    late web.Permissions permissions;
    try {
      permissions = web.window.navigator.permissions;
    } catch (e) {
      debugPrint('Browser Permissions API is unavailable for $name: $e');
      return 'unsupported';
    }

    try {
      final queryOptions = {'name': name}.jsify() as JSObject;
      final result = await permissions.query(queryOptions).toDart;
      switch (result.state) {
        case 'granted':
          return 'granted';
        case 'denied':
          return 'denied';
        case 'prompt':
        default:
          return 'notDetermined';
      }
    } catch (e) {
      // Some browsers lack Permissions.query or reject particular descriptors.
      // That says nothing about whether the underlying feature is available.
      debugPrint('Cannot query browser $name permission: $e');
      return 'notDetermined';
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

      final permissions = web.window.navigator.permissions;
      final queryOptions = {'name': 'notifications'}.jsify() as JSObject;
      final result = await permissions.query(queryOptions).toDart;

      final state = result.state;
      if (state == 'granted') {
        return 'granted';
      } else if (state == 'denied') {
        return 'denied';
      } else if (state == 'prompt') {
        // Request permission
        final permission = await web.Notification.requestPermission().toDart;
        return permission.toDart == 'granted' ? 'granted' : 'denied';
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
          return 'notDetermined';
      }
    } catch (e) {
      return 'error';
    }
  }

  // Web-specific permissions that are not applicable

  Future<String> requestRadiosPermission() async {
    // Radios permission is not applicable for web
    return 'unsupported';
  }

  Future<String> checkRadiosPermission() async {
    // Radios permission is not applicable for web
    return 'unsupported';
  }

  Future<String> requestVoiceActivationPermission() async {
    // Voice activation is handled through microphone permission in web
    return requestMicrophonePermissionWeb();
  }

  Future<String> checkVoiceActivationPermission() async {
    // Voice activation is handled through microphone permission in web
    return checkMicrophonePermissionWeb();
  }

  Future<String> requestEmailPermission() async {
    // Email permission is not applicable for web
    return 'unsupported';
  }

  Future<String> checkEmailPermission() async {
    // Email permission is not applicable for web
    return 'unsupported';
  }

  // Keep settings navigation in the caller's click stack, before any await.
  @override
  Future<void> openCameraSettings() {
    return _openSettings('Camera', 'privacy-webcam');
  }

  @override
  Future<void> openMicrophoneSettings() {
    return _openSettings('Microphone', 'privacy-microphone');
  }

  @override
  Future<void> openLocationSettings() {
    return _openSettings('Location', 'privacy-location');
  }

  @override
  Future<void> openNotificationSettings() {
    return _openSettings('Notification', 'notifications');
  }

  Future<void> openRadiosSettings() {
    return _openSettings('Radios', 'privacy-radios');
  }

  Future<void> openVoiceActivationSettings() {
    return _openSettings('Voice activation', 'privacy-voiceactivation');
  }

  Future<void> openEmailSettings() {
    return _openSettings('Email', 'privacy-email');
  }

  Future<void> _openSettings(String permissionType, String windowsPage) {
    if (web.window.navigator.userAgent.contains('Windows')) {
      try {
        // External protocols must be dispatched synchronously from a user
        // gesture. The browser can prompt or block this; there is no launch
        // confirmation and this does not grant the site's permission.
        web.window.location.href = 'ms-settings:$windowsPage';
        debugPrint(
          'Requested Windows $permissionType settings. The browser may prompt '
          'or block the request. If needed, open Windows Settings manually. '
          'Site permissions must also be managed in the browser.',
        );
      } catch (e) {
        debugPrint(
          'Could not request Windows $permissionType settings: $e. '
          'Open Windows Settings manually and check browser site permissions.',
        );
      }
    } else {
      _showBrowserSettingsMessage(permissionType);
    }
    return Future<void>.value();
  }

  void _showBrowserSettingsMessage(String permissionType) {
    debugPrint(
      'Cannot open system $permissionType settings directly on this platform. '
      'Use your browser address-bar site controls or browser privacy settings '
      'for supported site permissions, and your operating system Settings '
      'for system permissions.',
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
  Future<void> openCameraSettingsWindows() {
    return openCameraSettings();
  }

  @override
  Future<void> openMicrophoneSettingsWindows() {
    return openMicrophoneSettings();
  }

  @override
  Future<void> openLocationSettingsWindows() {
    return openLocationSettings();
  }

  @override
  Future<void> openNotificationSettingsWindows() {
    return openNotificationSettings();
  }

  @override
  Future<void> openRadiosSettingsWindows() {
    return openRadiosSettings();
  }

  Future<void> openVoiceActivationSettingsWindows() {
    return openVoiceActivationSettings();
  }

  Future<void> openEmailSettingsWindows() {
    return openEmailSettings();
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
  Future<void> openAppSettings() {
    return _openSettings('App', 'privacy');
  }

  @override
  Future<void> openAppSettingsWindows() {
    return openAppSettings();
  }

  @override
  Future<void> openSpeechSettingsWindows() {
    return _openSettings('Speech', 'privacy-speech');
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
    _showBrowserSettingsMessage('App');
  }

  @override
  Future<void> openAppSettingsLinux() async {
    _showBrowserSettingsMessage('App');
  }

  @override
  Future<String> requestBluetoothPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestCalendarPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestCameraPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestContactsPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestLocationPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestMicrophonePermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestNetworkPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestNotificationPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestStoragePermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestUsbPermissionLinux() async {
    return 'unsupported';
  }

  @override
  Future<String> requestHealthPermission() async {
    return 'unsupported';
  }
}
