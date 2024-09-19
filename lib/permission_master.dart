import 'permission_master_platform_interface.dart';

class PermissionMaster {
  Future<String?> getPlatformVersion() {
    return PermissionMasterPlatform.instance.getPlatformVersion();
  }

  // درخواست مجوز دوربین
  Future<bool> requestCameraPermission() {
    return PermissionMasterPlatform.instance.requestCameraPermission();
  }

  // درخواست مجوز لوکیشن
  Future<bool> requestLocationPermission() {
    return PermissionMasterPlatform.instance.requestLocationPermission();
  }

  // درخواست مجوز میکروفون
  Future<bool> requestMicrophonePermission() {
    return PermissionMasterPlatform.instance.requestMicrophonePermission();
  }

  // درخواست مجوز دسترسی به عکس‌ها
  Future<bool> requestPhotosPermission() {
    return PermissionMasterPlatform.instance.requestPhotosPermission();
  }

  Future<bool> requestBluetoothPermission() {
    return PermissionMasterPlatform.instance.requestBluetoothPermission();
  }

  // درخواست مجوز وای‌فای
  Future<bool> requestWiFiPermission() {
    return PermissionMasterPlatform.instance.requestWiFiPermission();
  }

  // درخواست مجوز سنسور مجاورتی
  Future<bool> requestProximitySensorPermission() {
    return PermissionMasterPlatform.instance.requestProximitySensorPermission();
  }

  // درخواست مجوز مخاطبین
  Future<bool> requestContactsPermission() {
    return PermissionMasterPlatform.instance.requestContactsPermission();
  }

  // درخواست مجوز نوتیفیکیشن
  Future<bool> requestNotificationPermission() {
    return PermissionMasterPlatform.instance.requestNotificationPermission();
  }
}
