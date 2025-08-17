// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final PermissionMaster permissionMaster = PermissionMaster();
  String? platformVersion;
  Map<PermissionType, PermissionStatus> permissionStatuses = {};
  bool isLoading = false;

  // Method to check if a permission is supported on this device
  bool isPermissionSupported(PermissionType permission) {
    final status = permissionStatuses[permission];
    return status != null && status != PermissionStatus.unsupported;
  }

  // Method to check if a permission is already granted
  bool isPermissionGranted(PermissionType permission) {
    final status = permissionStatuses[permission];
    return status == PermissionStatus.granted;
  }

  // Get the appropriate button text based on permission status
  String getButtonText(PermissionStatus? status) {
    if (status == null) return 'Request';

    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Request';
      case PermissionStatus.openSettings:
        return 'Settings';
      case PermissionStatus.unsupported:
        return 'Unsupported';
      default:
        return 'Request';
    }
  }

  @override
  void initState() {
    super.initState();
    PermissionMaster.setContext(context);
    _getPlatformVersion();
    _checkInitialPermissions();
  }

  Future<void> _getPlatformVersion() async {
    try {
      String version = (await permissionMaster.getPlatformVersion())!;
      setState(() {
        platformVersion = version;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _checkInitialPermissions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check status of common permissions
      final permissions = [
        PermissionType.camera,
        PermissionType.fineLocation,
        PermissionType.readStorage,
        PermissionType.microphone,
        PermissionType.contacts,
        PermissionType.bluetooth,
        PermissionType.notifications,
        PermissionType.alarm,
        PermissionType.calendar,
      ];

      for (var permission in permissions) {
        final status = await permissionMaster.checkPermissionStatus(
          permission.value,
        );
        setState(() {
          permissionStatuses[permission] = status;
        });
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestPermission(PermissionType permission) async {
    setState(() {
      isLoading = true;
    });

    try {
      PermissionStatus status;

      switch (permission) {
        case PermissionType.camera:
          status = await permissionMaster.requestCameraPermission();
          break;
        case PermissionType.fineLocation:
          status = await permissionMaster.requestLocationPermission();
          break;
        case PermissionType.readStorage:
          status = await permissionMaster.requestStoragePermission();
          break;
        case PermissionType.microphone:
          status = await permissionMaster.requestMicrophonePermission();
          break;
        case PermissionType.contacts:
          status = await permissionMaster.requestContactsPermission();
          break;
        case PermissionType.bluetooth:
          status = await permissionMaster.requestBluetoothPermission();
          break;
        case PermissionType.notifications:
          status = await permissionMaster.requestNotificationPermission();
          break;
        case PermissionType.alarm:
          status = await permissionMaster.requestAlarmPermission();
          break;
        case PermissionType.calendar:
          status = await permissionMaster.requestCalendarPermission();
          break;
        default:
          status = await permissionMaster.requestPermission(
            permission: permission,
          );
      }

      setState(() {
        permissionStatuses[permission] = status;
      });

      _showStatusSnackBar(permission, status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permission: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showStatusSnackBar(PermissionType permission, PermissionStatus status) {
    String message = 'Permission ${permission.name} is ${status.name}';
    Color backgroundColor;

    switch (status) {
      case PermissionStatus.granted:
        backgroundColor = Colors.green;
        break;
      case PermissionStatus.denied:
        backgroundColor = Colors.orange;
        break;
      case PermissionStatus.openSettings:
        backgroundColor = Colors.blue;
        message += '. Please open settings to grant permission.';
        break;
      case PermissionStatus.unsupported:
        backgroundColor = Colors.purple;
        message += '. This permission is not supported on your device.';
        break;
      default:
        backgroundColor = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        action:
            status == PermissionStatus.openSettings
                ? SnackBarAction(
                  label: 'Open Settings',
                  onPressed: () => permissionMaster.openAppSettings(),
                )
                : null,
      ),
    );
  }

  String _getStatusIcon(PermissionStatus? status) {
    if (status == null) return '❓';

    switch (status) {
      case PermissionStatus.granted:
        return '✅';
      case PermissionStatus.denied:
        return '❌';
      case PermissionStatus.openSettings:
        return '⚙️';
      case PermissionStatus.unsupported:
        return '⚠️';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permission Master Demo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _checkInitialPermissions,
            tooltip: 'Refresh permissions',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await permissionMaster.openAppSettings();
            },
            tooltip: 'Open app settings',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text('Platform: ${platformVersion ?? 'Unknown'}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Permissions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildPermissionsList(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showPermissionBottomSheet(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Request More Permissions'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPermissionsList() {
    return Card(
      elevation: 4,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: permissionStatuses.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final permission = permissionStatuses.keys.elementAt(index);
          final status = permissionStatuses[permission];

          final bool isSupported = status != PermissionStatus.unsupported;
          final bool isGranted = status == PermissionStatus.granted;
          final bool needsSettings = status == PermissionStatus.openSettings;

          Color getButtonColor() {
            if (!isSupported) return Colors.grey;
            if (isGranted) return Colors.green;
            if (needsSettings) return Colors.blue;
            return Colors.deepPurple;
          }

          VoidCallback? getButtonAction() {
            if (!isSupported) return null;
            if (needsSettings) return () => permissionMaster.openAppSettings();
            return () => _requestPermission(permission);
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Text(
                _getStatusIcon(status),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(permission.name),
            subtitle: Text('Status: ${status?.name ?? 'Unknown'}'),
            trailing: ElevatedButton(
              onPressed: getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: getButtonColor(),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade700,
              ),
              child: Text(getButtonText(status)),
            ),
          );
        },
      ),
    );
  }

  void _showPermissionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Permissions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildPermissionButton(
                          PermissionType.camera,
                          'Camera',
                          Icons.camera_alt,
                        ),
                        _buildPermissionButton(
                          PermissionType.fineLocation,
                          'Location',
                          Icons.location_on,
                        ),
                        _buildPermissionButton(
                          PermissionType.readStorage,
                          'Storage',
                          Icons.sd_storage,
                        ),
                        _buildPermissionButton(
                          PermissionType.microphone,
                          'Microphone',
                          Icons.mic,
                        ),
                        _buildPermissionButton(
                          PermissionType.contacts,
                          'Contacts',
                          Icons.contacts,
                        ),
                        _buildPermissionButton(
                          PermissionType.bluetooth,
                          'Bluetooth',
                          Icons.bluetooth,
                        ),
                        _buildPermissionButton(
                          PermissionType.notifications,
                          'Notifications',
                          Icons.notifications,
                        ),
                        _buildPermissionButton(
                          PermissionType.alarm,
                          'Alarm',
                          Icons.alarm,
                        ),
                        _buildPermissionButton(
                          PermissionType.calendar,
                          'Calendar',
                          Icons.calendar_today,
                        ),
                        _buildPermissionButton(
                          PermissionType.phone,
                          'Phone',
                          Icons.phone,
                        ),
                        _buildPermissionButton(
                          PermissionType.sms,
                          'SMS',
                          Icons.sms,
                        ),
                        _buildPermissionButton(
                          PermissionType.activityRecognition,
                          'Activity Recognition',
                          Icons.directions_run,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionButton(
    PermissionType permission,
    String label,
    IconData icon,
  ) {
    // Check if the permission is already in our status map
    final status = permissionStatuses[permission];
    final bool isSupported = status != PermissionStatus.unsupported;
    final bool isGranted = status == PermissionStatus.granted;

    // Determine button color based on status
    Color getButtonColor() {
      if (status == null) return Colors.deepPurple;
      if (!isSupported) return Colors.grey;
      if (isGranted) return Colors.green;
      return Colors.deepPurple;
    }

    // Determine if button should be enabled
    bool isEnabled = status == null || isSupported;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed:
            isEnabled
                ? () {
                  Navigator.pop(context);
                  _requestPermission(permission);
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: getButtonColor(),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade700,
          minimumSize: const Size(double.infinity, 50),
        ),
        icon: Icon(icon),
        label: Text(status != null ? '$label (${status.name})' : label),
      ),
    );
  }
}
