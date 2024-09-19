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
}
