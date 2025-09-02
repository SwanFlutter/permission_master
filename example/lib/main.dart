// ignore_for_file: unreachable_switch_default, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master_example/test_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_master_example/windows_example_screen.dart';
import 'package:permission_master_example/web_example_screen.dart';
import 'package:permission_master_example/macos_example_screen.dart';
import 'package:permission_master_example/linux_example_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Master Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: kIsWeb 
          ? const WebExampleScreen() 
          : Platform.isWindows 
              ? const WindowsExampleScreen()
              : Platform.isMacOS
                  ? const MacOSExampleScreen()
                  : Platform.isLinux
                      ? const LinuxExampleScreen()
                      : const PermissionDemoPage(),
    );
  }
}

class PermissionDemoPage extends StatefulWidget {
  const PermissionDemoPage({super.key});

  @override
  State<PermissionDemoPage> createState() => _PermissionDemoPageState();
}

class _PermissionDemoPageState extends State<PermissionDemoPage> {
  final PermissionMaster _permissionMaster = PermissionMaster();
  final Map<String, PermissionStatus> _permissionStatus = {};
  final Map<String, int> _permissionAttempts = {};
  final GetStorageBridge _storage = GetStorageBridge();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionMaster.setContext(context);
      _checkInitialPermissions();
    });

    _loadPermissionAttempts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPermissionAttempts() async {
    final attempts = await _storage.read<Map<String, int>>(
      'permission_attempts',
      {},
    );
    setState(() {
      _permissionAttempts.addAll(attempts);
    });
  }

  Future<void> _savePermissionAttempts() async {
    await _storage.write('permission_attempts', _permissionAttempts);
  }

  Future<void> _checkInitialPermissions() async {
    final permissions = [
      PermissionType.camera,
      PermissionType.fineLocation,
      PermissionType.backgroundLocation,
      PermissionType.readStorage,
      PermissionType.writeStorage,
      PermissionType.microphone,
      PermissionType.contacts,
      PermissionType.bluetooth,
      PermissionType.bluetoothAdmin,
      PermissionType.bluetoothScan,
      PermissionType.bluetoothAdvertise,
      PermissionType.bluetoothConnect,
      PermissionType.bodySensors,
      PermissionType.accessWifi,
      PermissionType.changeWifi,
      PermissionType.sms,
      PermissionType.notifications,
      PermissionType.alarm,
      PermissionType.calendar,
      PermissionType.phone,
      PermissionType.activityRecognition,
      PermissionType.nearbyDevices,
    ];

    final status = await _permissionMaster.checkMultiplePermissions(
      permissions,
    );
    if (mounted) {
      setState(() {
        _permissionStatus.addAll(status);
      });
    }
  }

  Future<void> _requestPermission(
    String title,
    String permission,
    Future<PermissionStatus> Function() requestFunc,
  ) async {
    try {
      final attempts = _permissionAttempts[permission] ?? 0;

      if (attempts >= 2 &&
          _permissionStatus[permission] != PermissionStatus.granted) {
        final status = await _permissionMaster.checkPermissionStatus(
          permission,
        );

        if (status != PermissionStatus.granted) {
          final bool? openSettings = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('$title Permission Required'),
              content: const Text(
                'You have denied this permission multiple times. '
                'Please enable it from settings to use this feature.',
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
            ),
          );

          if (openSettings == true) {
            try {
              await _permissionMaster.openAppSettings();

              // کمی صبر کنید تا کاربر برگردد
              await Future.delayed(const Duration(seconds: 1));

              final newStatus = await _permissionMaster.checkPermissionStatus(
                permission,
              );
              _updatePermissionStatus(title, permission, newStatus);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to open settings: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          return;
        }
      }

      // کد اصلی برای درخواست مجوز (بدون تغییر)
      if (attempts > 0 &&
          _permissionStatus[permission] != PermissionStatus.granted) {
        final bool? shouldRequest = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('$title Permission Required'),
            content: Text(
              'This permission is required for $title functionality. '
              'Would you like to grant it now?',
            ),
            actions: [
              TextButton(
                child: const Text('No, thanks'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Grant Permission'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (shouldRequest != true) {
          return;
        }
      }

      setState(() {
        _permissionAttempts[permission] = attempts + 1;
      });
      await _savePermissionAttempts();

      final result = await requestFunc();
      _updatePermissionStatus(title, permission, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting $title permission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updatePermissionStatus(
    String title,
    String permission,
    PermissionStatus result,
  ) {
    if (mounted) {
      setState(() {
        _permissionStatus[permission] = result;
      });

      String message;
      Color backgroundColor;
      switch (result) {
        case PermissionStatus.granted:
          message = '$title permission granted!';
          backgroundColor = Colors.green;
          break;
        case PermissionStatus.denied:
          message = '$title permission denied!';
          backgroundColor = Colors.red;
          break;
        case PermissionStatus.openSettings:
          message = '$title permission requires settings change.';
          backgroundColor = Colors.orange;
          break;
        case PermissionStatus.error:
          message = 'Error with $title permission!';
          backgroundColor = Colors.red;
          break;
        default:
          message = 'Unknown status for $title permission!';
          backgroundColor = Colors.red;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required IconData icon,
    required String permission,
    required Future<PermissionStatus> Function() onRequest,
  }) {
    final status = _permissionStatus[permission];
    final attempts = _permissionAttempts[permission] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            if (attempts > 0)
              Text(
                'Requested $attempts ${attempts == 1 ? 'time' : 'times'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != null)
              Icon(
                status == PermissionStatus.granted
                    ? Icons.check_circle
                    : Icons.cancel,
                color: status == PermissionStatus.granted
                    ? Colors.green
                    : Colors.red,
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: attempts >= 2 && status != PermissionStatus.granted
                  ? () => _requestPermission(title, permission, onRequest)
                  : () => _requestPermission(title, permission, onRequest),
              child: Text(
                attempts >= 2 && status != PermissionStatus.granted
                    ? 'Open Settings'
                    : 'Request',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Master Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkInitialPermissions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: ListView(
          children: [
            _buildPermissionCard(
              title: 'Camera',
              description: 'Required for taking photos and video calls',
              icon: Icons.camera_alt,
              permission: PermissionType.camera.value,
              onRequest: _permissionMaster.requestCameraPermission,
            ),
            _buildPermissionCard(
              title: 'Location',
              description: 'Required for location-based features',
              icon: Icons.location_on,
              permission: PermissionType.fineLocation.value,
              onRequest: _permissionMaster.requestLocationPermission,
            ),
            _buildPermissionCard(
              title: 'Storage',
              description: 'Required for saving files and media',
              icon: Icons.storage,
              permission: PermissionType.readStorage.value,
              onRequest: _permissionMaster.requestStoragePermission,
            ),
            _buildPermissionCard(
              title: 'Microphone',
              description: 'Required for voice messages and calls',
              icon: Icons.mic,
              permission: PermissionType.microphone.value,
              onRequest: _permissionMaster.requestMicrophonePermission,
            ),
            _buildPermissionCard(
              title: 'Contacts',
              description: 'Required for finding your friends',
              icon: Icons.contacts,
              permission: PermissionType.contacts.value,
              onRequest: _permissionMaster.requestContactsPermission,
            ),
            _buildPermissionCard(
              title: 'Bluetooth',
              description: 'Required for connecting to Bluetooth devices',
              icon: Icons.bluetooth,
              permission: PermissionType.bluetooth.value,
              onRequest: _permissionMaster.requestBluetoothPermission,
            ),
            _buildPermissionCard(
              title: 'Sensors',
              description: 'Required for fitness tracking features',
              icon: Icons.sensors,
              permission: PermissionType.bodySensors.value,
              onRequest: _permissionMaster.requestSensorsPermission,
            ),
            _buildPermissionCard(
              title: 'WiFi',
              description: 'Required for WiFi connectivity features',
              icon: Icons.wifi,
              permission: PermissionType.accessWifi.value,
              onRequest: _permissionMaster.requestWifiPermission,
            ),
            _buildPermissionCard(
              title: 'SMS',
              description: 'Required for sending and receiving SMS',
              icon: Icons.sms,
              permission: PermissionType.sms.value,
              onRequest: _permissionMaster.requestSmsPermission,
            ),
            _buildPermissionCard(
              title: 'Notifications',
              description: 'Required for sending notifications',
              icon: Icons.notifications,
              permission: PermissionType.notifications.value,
              onRequest: _permissionMaster.requestNotificationPermission,
            ),
            _buildPermissionCard(
              title: 'Alarm',
              description: 'Required for scheduling alarms',
              icon: Icons.alarm,
              permission: PermissionType.alarm.value,
              onRequest: _permissionMaster.requestAlarmPermission,
            ),
            _buildPermissionCard(
              title: 'Calendar',
              description: 'Required for calendar access',
              icon: Icons.calendar_today,
              permission: PermissionType.calendar.value,
              onRequest: _permissionMaster.requestCalendarPermission,
            ),
            _buildPermissionCard(
              title: 'Phone',
              description: 'Required for call-related features',
              icon: Icons.phone,
              permission: PermissionType.phone.value,
              onRequest: _permissionMaster.requestPhonePermission,
            ),
            _buildPermissionCard(
              title: 'Activity Recognition',
              description: 'Required for fitness tracking',
              icon: Icons.directions_run,
              permission: PermissionType.activityRecognition.value,
              onRequest: _permissionMaster.requestActivityRecognitionPermission,
            ),
            _buildPermissionCard(
              title: 'Nearby Devices',
              description: 'Required for discovering nearby devices',
              icon: Icons.devices_other,
              permission: PermissionType.nearbyDevices.value,
              onRequest: _permissionMaster.requestNearbyDevicesPermission,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TestScreen()),
          );
        },
        tooltip: 'Advanced Tests',
        child: const Icon(Icons.science),
      ),
    );
  }
}
