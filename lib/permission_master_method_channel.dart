import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'permission_master_platform_interface.dart';

/// An implementation of [PermissionMasterPlatform] that uses method channels.class MethodChannelPermissionMaster extends PermissionMasterPlatform {
class MethodChannelPermissionMaster extends PermissionMasterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('permission_master');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestCameraPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestLocationPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestMicrophonePermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestPhotosPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestPhotosPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestBluetoothPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestBluetoothPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestWiFiPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestWiFiPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestProximitySensorPermission() async {
    final granted = await methodChannel
        .invokeMethod<bool>('requestProximitySensorPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestContactsPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestContactsPermission');
    return granted ?? false;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final granted =
        await methodChannel.invokeMethod<bool>('requestNotificationPermission');
    return granted ?? false;
  }
}
