import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

class TestPermissionDialog extends StatefulWidget {
  const TestPermissionDialog({super.key});

  @override
  State<TestPermissionDialog> createState() => _TestPermissionDialogState();
}

class _TestPermissionDialogState extends State<TestPermissionDialog> {
  String _permissionStatus = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Permission Dialog')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Permission Status: $_permissionStatus',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: const Text('Request Camera Permission'),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestMultiplePermissionsWithDialogs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              child: const Text('Request Multiple Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await PermissionMaster().requestPermissionWithDialog(
        permission: PermissionType.camera,
        title: 'Camera Permission',
        message: 'This app needs camera access to take photos.',
      );
      setState(() {
        _permissionStatus = 'Camera: ${status.name}';
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _requestMultiplePermissionsWithDialogs() async {
    final permissionMaster = PermissionMaster();

    final permissions = [
      PermissionType.camera,
      PermissionType.fineLocation,
      PermissionType.microphone,
      PermissionType.contacts,
      PermissionType.notifications,
    ];

    final results = <String, PermissionStatus>{};

    setState(() {
      _permissionStatus = 'Requesting multiple permissions...';
    });

    // Request each permission one by one with dialog
    for (var permission in permissions) {
      try {
        final status = await permissionMaster.requestPermissionWithDialog(
          permission: permission,
          title: '${permission.name} Permission Required',
          message:
              'Please allow ${permission.name} permission to use this feature.',
        );

        results[permission.value] = status;

        switch (status) {
          case PermissionStatus.granted:
            print('✅ ${permission.name} is granted');
            break;
          case PermissionStatus.denied:
            print('❌ ${permission.name} is denied');
            break;
          case PermissionStatus.openSettings:
            print('⚠️ ${permission.name} needs settings adjustment');
            await permissionMaster.openAppSettings();
            break;
          case PermissionStatus.unsupported:
            print('🚫 ${permission.name} is not supported');
            break;
          case PermissionStatus.error:
            print('💥 Error with ${permission.name}');
            break;
        }
      } catch (e) {
        print('Error requesting ${permission.name}: $e');
        results[permission.value] = PermissionStatus.error;
      }
    }

    print('All permissions requested. Results: $results');

    setState(() {
      final grantedCount = results.values
          .where((status) => status == PermissionStatus.granted)
          .length;
      _permissionStatus =
          'Multiple permissions completed: $grantedCount/${permissions.length} granted';
    });
  }
}
