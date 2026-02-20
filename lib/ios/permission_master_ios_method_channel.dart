import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'permission_master_ios_platform_interface.dart';

/// An implementation of [PermissionMasterIosPlatform] that uses method channels.
class MethodChannelPermissionMasterIos extends PermissionMasterIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('permission_master_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String> requestCameraPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestCameraPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestPhotosPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestPhotosPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestLocationPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestLocationPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestContactsPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestContactsPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestBluetoothPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestBluetoothPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestMicrophonePermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestMicrophonePermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestNotificationPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestNotificationPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestCalendarPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestCalendarPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestMotionPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestMotionPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestSpeechPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestSpeechPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestRemindersPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestRemindersPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestMusicPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestMusicPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> requestHealthPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'requestHealthPermission',
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<String> checkPermissionStatus(String permission) async {
    final status = await methodChannel.invokeMethod<String>(
      'checkPermissionStatus',
      {'permission': permission},
    );
    return status ?? 'notDetermined';
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('openAppSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
