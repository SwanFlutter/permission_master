import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/permission_master_method_channel.dart';

class NewTestMultyPermission extends StatefulWidget {
  const NewTestMultyPermission({super.key});

  @override
  State<NewTestMultyPermission> createState() => _NewTestMultyPermissionState();
}

class _NewTestMultyPermissionState extends State<NewTestMultyPermission> {
  PermissionMaster permissionMaster = PermissionMaster();

  Future<void> checkMultiplePermissions() async {
    debugPrint('Requesting multiple permissions with dialogs...');

    final permissions = [
      PermissionType.camera,
      PermissionType.fineLocation,
      PermissionType.microphone,
      PermissionType.contacts,
      PermissionType.notifications,
    ];

    final results = <String, PermissionStatus>{};

    // Request each permission one by one with dialog
    for (var permission in permissions) {
      debugPrint('Requesting $permission...');

      final status = await permissionMaster.requestPermissionWithDialog(
        permission: permission,
        title:
            'دسترسی ${_getPermissionNameInPersian(permission)} مورد نیاز است',
        message:
            'لطفاً برای استفاده از این قابلیت، دسترسی ${_getPermissionNameInPersian(permission)} را اعطا کنید.',
      );

      results[permission.value] = status;

      debugPrint('$permission status: $status');

      switch (status) {
        case PermissionStatus.granted:
          debugPrint('✅ $permission is granted');
          break;
        case PermissionStatus.denied:
          debugPrint('❌ $permission is denied');
          break;
        case PermissionStatus.openSettings:
          debugPrint('⚠️ $permission needs settings adjustment');
          break;
        case PermissionStatus.unsupported:
          debugPrint('🚫 $permission is not supported');
          break;
        case PermissionStatus.error:
          debugPrint('💥 Error with $permission');
          break;
      }
    }

    debugPrint('All permissions requested. Results: $results');
  }

  String _getPermissionNameInPersian(PermissionType permission) {
    switch (permission) {
      case PermissionType.camera:
        return 'دوربین';
      case PermissionType.fineLocation:
        return 'موقعیت مکانی';
      case PermissionType.microphone:
        return 'میکروفون';
      case PermissionType.contacts:
        return 'مخاطبین';
      case PermissionType.notifications:
        return 'اعلان‌ها';
      default:
        return permission.name;
    }
  }

  Future<void> requestMultiplePermissions() async {
    debugPrint('Requesting multiple permissions with dialogs...');

    final permissions = [
      'android.permission.CAMERA',
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.RECORD_AUDIO',
      'android.permission.READ_CONTACTS',
      'android.permission.POST_NOTIFICATIONS',
    ];

    try {
      // Use the native requestDynamicPermissions method
      final methodChannel = MethodChannelPermissionMaster();
      final result = await methodChannel.requestDynamicPermissions(permissions);

      debugPrint('Request multiple permissions result: $result');

      result.forEach((permission, status) {
        debugPrint('$permission status: $status');
        if (status == 'GRANTED') {
          debugPrint('✅ $permission is granted');
        } else {
          debugPrint('❌ $permission is $status');
        }
      });
    } catch (e) {
      debugPrint('Error requesting multiple permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NewTestMultyPermission')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Center(child: Text('NewTestMultyPermission')),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await checkMultiplePermissions();
              },
              child: Text('Check Permissions Status'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await requestMultiplePermissions();
              },
              child: Text('Request Permissions (with Dialogs)'),
            ),
          ],
        ),
      ),
    );
  }
}
