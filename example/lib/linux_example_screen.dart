// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

class LinuxExampleScreen extends StatefulWidget {
  const LinuxExampleScreen({super.key});

  @override
  State<LinuxExampleScreen> createState() => _LinuxExampleScreenState();
}

class _LinuxExampleScreenState extends State<LinuxExampleScreen> {
  Map<String, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = false;

  final List<PermissionTypeLinux> _permissions = [
    PermissionTypeLinux.camera,
    PermissionTypeLinux.microphone,
    PermissionTypeLinux.location,
    PermissionTypeLinux.storage,
    PermissionTypeLinux.contacts,
    PermissionTypeLinux.calendar,
    PermissionTypeLinux.notification,
    PermissionTypeLinux.bluetooth,
    PermissionTypeLinux.network,
    PermissionTypeLinux.usb,
  ];

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For now, set default status as denied for Linux permissions
      Map<String, PermissionStatus> statuses = {};
      for (final permission in _permissions) {
        // Set default status as denied for now
        statuses[permission.toString()] = PermissionStatus.denied;
      }

      setState(() {
        _permissionStatuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking permissions: \$e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission(PermissionTypeLinux permission) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String result = 'denied';

      switch (permission) {
        case PermissionTypeLinux.camera:
          result = await PermissionMaster().requestCameraPermissionLinux();
          break;
        case PermissionTypeLinux.microphone:
          result = await PermissionMaster().requestMicrophonePermissionLinux();
          break;
        case PermissionTypeLinux.location:
          result = await PermissionMaster().requestLocationPermissionLinux();
          break;
        case PermissionTypeLinux.storage:
          result = await PermissionMaster().requestStoragePermissionLinux();
          break;
        case PermissionTypeLinux.contacts:
          result = await PermissionMaster().requestContactsPermissionLinux();
          break;
        case PermissionTypeLinux.calendar:
          result = await PermissionMaster().requestCalendarPermissionLinux();
          break;
        case PermissionTypeLinux.notification:
          result = await PermissionMaster()
              .requestNotificationPermissionLinux();
          break;
        case PermissionTypeLinux.bluetooth:
          result = await PermissionMaster().requestBluetoothPermissionLinux();
          break;
        case PermissionTypeLinux.network:
          result = await PermissionMaster().requestNetworkPermissionLinux();
          break;
        case PermissionTypeLinux.usb:
          result = await PermissionMaster().requestUsbPermissionLinux();
          break;
        default:
          result = 'unsupported';
      }

      debugPrint('\$permission permission result: \$result');

      // Convert string result to PermissionStatus
      PermissionStatus status;
      switch (result.toLowerCase()) {
        case 'granted':
          status = PermissionStatus.granted;
          break;
        case 'denied':
        case 'not_determined':
        case 'restricted':
        case 'permanently_denied':
          status = PermissionStatus.denied;
          break;
        case 'unsupported':
          status = PermissionStatus.unsupported;
          break;
        default:
          status = PermissionStatus.error;
      }

      setState(() {
        _permissionStatuses[permission.toString()] = status;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error requesting \$permission permission: \$e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await PermissionMaster().openAppSettingsLinux();
    } catch (e) {
      debugPrint('Error opening app settings: \$e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
      case 'permanently_denied':
        return Colors.red;
      case 'restricted':
        return Colors.orange;
      case 'not_determined':
        return Colors.blue;
      case 'not_supported':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Icons.check_circle;
      case 'denied':
      case 'permanently_denied':
        return Icons.cancel;
      case 'restricted':
        return Icons.warning;
      case 'not_determined':
        return Icons.help;
      case 'not_supported':
        return Icons.not_interested;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linux Permissions'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAllPermissions,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openAppSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Linux Permission Status:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _permissions.length,
                      itemBuilder: (context, index) {
                        final permission = _permissions[index];
                        final status =
                            _permissionStatuses[permission.toString()] ??
                            PermissionStatus.denied;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              _getStatusIcon(status.toString().split('.').last),
                              color: _getStatusColor(
                                status.toString().split('.').last,
                              ),
                              size: 32,
                            ),
                            title: Text(
                              permission
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              status.toString().split('.').last,
                              style: TextStyle(
                                color: _getStatusColor(
                                  status.toString().split('.').last,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: status == PermissionStatus.granted
                                  ? null
                                  : () => _requestPermission(permission),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    status == PermissionStatus.granted
                                    ? Colors.grey
                                    : Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                status == PermissionStatus.granted
                                    ? 'Granted'
                                    : 'Request',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: This screen demonstrates Linux-specific permissions. '
                    'Some permissions may require additional system configuration.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
