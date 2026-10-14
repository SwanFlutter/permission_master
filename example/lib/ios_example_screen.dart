// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

class IosExampleScreen extends StatefulWidget {
  const IosExampleScreen({super.key});

  @override
  State<IosExampleScreen> createState() => _IosExampleScreenState();
}

class _IosExampleScreenState extends State<IosExampleScreen> {
  final _plugin = PermissionMaster();
  String _platformVersion = 'Unknown';
  final Map<String, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    try {
      final version = await _plugin.getPlatformVersion() ?? 'Unknown';
      setState(() {
        _platformVersion = version;
      });
    } catch (e) {
      setState(() {
        _platformVersion = 'Failed to get platform version';
      });
    }
  }

  Future<void> _requestPermission(
    String name,
    Future<PermissionStatus> Function() request,
  ) async {
    try {
      final status = await request();
      setState(() {
        _permissionStatuses[name] = status;
      });

      if (mounted) {
        // If permission is denied, show dialog to open settings
        if (status == PermissionStatus.denied) {
          _showOpenSettingsDialog(name);
        } else if (status == PermissionStatus.unsupported) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$name: This permission is not supported on this device',
              ),
              backgroundColor: _getStatusColor(status),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name: ${status.name}'),
              backgroundColor: _getStatusColor(status),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showOpenSettingsDialog(String permissionName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: Text(
            '$permissionName permission was denied. Would you like to open settings to enable it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final opened = await _plugin.openAppSettings();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          opened
                              ? 'Settings opened successfully'
                              : 'Failed to open settings',
                        ),
                        backgroundColor: opened ? Colors.green : Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening settings: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.orange;
      case PermissionStatus.limited:
        return Colors.amber;
      case PermissionStatus.unsupported:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Icons.check_circle;
      case PermissionStatus.denied:
        return Icons.cancel;
      case PermissionStatus.restricted:
        return Icons.block;
      case PermissionStatus.limited:
        return Icons.warning;
      case PermissionStatus.unsupported:
        return Icons.do_not_disturb_on;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permission Master iOS'), elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Running on: $_platformVersion'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Request Permissions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPermissionTile(
            'Camera',
            Icons.camera_alt,
            () => _requestPermission('Camera', _plugin.requestCameraPermission),
          ),
          _buildPermissionTile(
            'Photos',
            Icons.photo_library,
            () => _requestPermission('Photos', _plugin.requestPhotosPermission),
          ),
          _buildPermissionTile(
            'Microphone',
            Icons.mic,
            () => _requestPermission(
              'Microphone',
              _plugin.requestMicrophonePermission,
            ),
          ),
          _buildPermissionTile(
            'Location',
            Icons.location_on,
            () => _requestPermission(
              'Location',
              _plugin.requestLocationPermission,
            ),
          ),
          _buildPermissionTile(
            'Contacts',
            Icons.contacts,
            () => _requestPermission(
              'Contacts',
              _plugin.requestContactsPermission,
            ),
          ),
          _buildPermissionTile(
            'Calendar',
            Icons.calendar_today,
            () => _requestPermission(
              'Calendar',
              _plugin.requestCalendarPermission,
            ),
          ),
          _buildPermissionTile(
            'Reminders',
            Icons.alarm,
            () => _requestPermission(
              'Reminders',
              _plugin.requestRemindersPermission,
            ),
          ),
          _buildPermissionTile(
            'Notifications',
            Icons.notifications,
            () => _requestPermission(
              'Notifications',
              _plugin.requestNotificationPermission,
            ),
          ),
          _buildPermissionTile(
            'Bluetooth',
            Icons.bluetooth,
            () => _requestPermission(
              'Bluetooth',
              _plugin.requestBluetoothPermission,
            ),
          ),
          _buildPermissionTile(
            'Motion & Fitness',
            Icons.directions_run,
            () => _requestPermission('Motion', _plugin.requestMotionPermission),
          ),
          _buildPermissionTile(
            'Speech Recognition',
            Icons.record_voice_over,
            () => _requestPermission('Speech', _plugin.requestSpeechPermission),
          ),
          _buildPermissionTile(
            'Media Library',
            Icons.library_music,
            () => _requestPermission('Music', _plugin.requestMusicPermission),
          ),
          _buildPermissionTile(
            'Health',
            Icons.favorite,
            _requestHealthPermission,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '⚠️ Health only works on real iOS devices, not Simulator',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _testStorage,
            icon: const Icon(Icons.storage),
            label: const Text('Test Storage'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _testOpenSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Test Open Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(String title, IconData icon, VoidCallback onTap) {
    final status = _permissionStatuses[title];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: status != null
            ? Icon(_getStatusIcon(status), color: _getStatusColor(status))
            : const Icon(Icons.arrow_forward_ios, size: 16),
        subtitle: status != null ? Text(status.name) : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _testStorage() async {
    try {
      final storage = _plugin.storage;

      await storage.write('test_key', 'Hello from iOS!');
      await storage.write('test_number', 42);
      await storage.write('test_map', {'name': 'Flutter', 'version': '3.0'});

      final stringValue = await storage.read('test_key', '');
      final numberValue = await storage.read('test_number', 0);
      final mapValue = await storage.read('test_map', <String, dynamic>{});

      final exists = await storage.contains('test_key');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Storage Test Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('String: $stringValue'),
                Text('Number: $numberValue'),
                Text('Map: $mapValue'),
                Text('Key exists: $exists'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testOpenSettings() async {
    try {
      debugPrint('🔧 Testing openAppSettings...');
      final result = await _plugin.openAppSettings();
      debugPrint('🔧 openAppSettings result: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? '✅ Settings opened successfully!'
                  : '❌ Failed to open settings',
            ),
            backgroundColor: result ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔧 Error in openAppSettings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _requestHealthPermission() async {
    try {
      final status = await _plugin.requestHealthPermission();
      setState(() {
        _permissionStatuses['Health'] = status;
      });

      if (mounted) {
        if (status == PermissionStatus.unsupported) {
          // Show special dialog for unsupported (Simulator)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('⚠️ Not Available'),
              content: const Text(
                'Health data is only available on real iOS devices.\n\n'
                'Please test this permission on an iPhone, not Simulator.\n\n'
                'Health permission allows access to:\n'
                '• Step Count\n'
                '• Heart Rate\n'
                '• Workouts\n'
                '• Active Energy\n'
                '• Walking + Running Distance',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (status == PermissionStatus.denied) {
          _showOpenSettingsDialog('Health');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Health: ${status.name}'),
              backgroundColor: _getStatusColor(status),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
