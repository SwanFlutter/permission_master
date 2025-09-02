// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master/src/permission_type.dart';

/// Web-specific example screen for demonstrating browser permission handling
class WebExampleScreen extends StatefulWidget {
  const WebExampleScreen({super.key});

  @override
  State<WebExampleScreen> createState() => _WebExampleScreenState();
}

class _WebExampleScreenState extends State<WebExampleScreen> {
  final PermissionMaster _permissionMaster = PermissionMaster();
  String? _platformVersion;
  bool _isLoading = false;
  final List<String> _logs = [];
  final Map<String, String> _permissionStatuses = {
    'camera': 'Unknown',
    'microphone': 'Unknown',
    'location': 'Unknown',
    'notification': 'Unknown',
  };

  @override
  void initState() {
    super.initState();
    PermissionMaster.setContext(context);
    _initializeWebExample();
  }

  Future<void> _initializeWebExample() async {
    if (!kIsWeb) {
      _addLog('⚠️ This example is designed for Web platform only');
      return;
    }

    await _getPlatformVersion();
    await _checkInitialPermissions();
  }

  Future<void> _getPlatformVersion() async {
    try {
      final version = await _permissionMaster.getPlatformVersion();
      setState(() {
        _platformVersion = version;
      });
      _addLog('📱 Platform Version: $version');
    } catch (e) {
      _addLog('❌ Error getting platform version: $e');
    }
  }

  Future<void> _checkInitialPermissions() async {
    if (!kIsWeb) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check HTTPS context
      final isHttps =
          Uri.base.scheme == 'https' || Uri.base.host == 'localhost';
      if (!isHttps) {
        _addLog('⚠️ WARNING: Permissions require HTTPS or localhost context');
        _addLog(
          '💡 Please serve this app over HTTPS or use localhost for testing',
        );
      }

      await _checkAllPermissions();
    } catch (e) {
      _addLog('❌ Error checking initial permissions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAllPermissions() async {
    _addLog('🔍 Checking all permissions...');
    await _checkCameraPermission();
    await _checkMicrophonePermission();
    await _checkLocationPermission();
    await _checkNotificationPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await _permissionMaster.checkPermissionStatus(
        PermissionType.camera.value,
      );
      setState(() {
        _permissionStatuses['camera'] = status.toString().split('.').last;
      });
      _addLog('📷 Camera permission: $status');
    } catch (e) {
      _addLog('❌ Error checking camera permission: $e');
    }
  }

  Future<void> _checkMicrophonePermission() async {
    try {
      final status = await _permissionMaster.checkPermissionStatus(
        PermissionType.microphone.value,
      );
      setState(() {
        _permissionStatuses['microphone'] = status.toString().split('.').last;
      });
      _addLog('🎤 Microphone permission: $status');
    } catch (e) {
      _addLog('❌ Error checking microphone permission: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      final status = await _permissionMaster.checkPermissionStatus(
        PermissionType.fineLocation.value,
      );
      setState(() {
        _permissionStatuses['location'] = status.toString().split('.').last;
      });
      _addLog('📍 Location permission: $status');
    } catch (e) {
      _addLog('❌ Error checking location permission: $e');
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final status = await _permissionMaster.checkPermissionStatus(
        PermissionType.notifications.value,
      );
      setState(() {
        _permissionStatuses['notification'] = status.toString().split('.').last;
      });
      _addLog('🔔 Notification permission: $status');
    } catch (e) {
      _addLog('❌ Error checking notification permission: $e');
    }
  }

  Future<void> _requestPermission(String permissionType) async {
    if (!kIsWeb) {
      _addLog('⚠️ $permissionType permission request is only available on Web');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🔄 Requesting $permissionType permission...');
      String result;

      PermissionStatus permissionResult;
      switch (permissionType) {
        case 'camera':
          permissionResult = await _permissionMaster.requestCameraPermission();
          break;
        case 'microphone':
          permissionResult = await _permissionMaster
              .requestMicrophonePermission();
          break;
        case 'location':
          permissionResult = await _permissionMaster
              .requestLocationPermission();
          break;
        case 'notification':
          permissionResult = await _permissionMaster
              .requestNotificationPermission();
          break;
        default:
          permissionResult = PermissionStatus.error;
      }
      result = permissionResult.toString().split('.').last;

      setState(() {
        _permissionStatuses[permissionType] = result;
      });
      _addLog('✅ $permissionType Permission Result: $result');

      if (result == 'denied') {
        _addLog(
          '💡 Tip: Check browser settings or click "Open Settings" to manually grant permission',
        );
        _addLog(
          '🔐 Note: Some permissions require HTTPS context and user interaction',
        );
      } else if (result == 'unsupported') {
        _addLog('⚠️ This permission is not supported on this browser/device');
      } else if (result == 'error') {
        _addLog('❌ An error occurred. Check browser console for details');
      }
    } catch (e) {
      _addLog('❌ Error requesting $permissionType permission: $e');
      _addLog('💡 Check browser console for detailed error information');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openSettings(String settingsType) async {
    if (!kIsWeb) {
      _addLog('⚠️ Opening $settingsType settings is only available on Web');
      return;
    }

    try {
      _addLog('🔧 Opening browser $settingsType settings...');

      switch (settingsType) {
        case 'camera':
          await _permissionMaster.openCameraSettings();
          break;
        case 'microphone':
          await _permissionMaster.openMicrophoneSettings();
          break;
        case 'location':
          await _permissionMaster.openLocationSettings();
          break;
        case 'notification':
          await _permissionMaster.openNotificationSettings();
          break;
      }

      _addLog('✅ $settingsType settings opened successfully');

      // Wait a bit and then recheck permission
      await Future.delayed(const Duration(seconds: 2));
      await _recheckPermission(settingsType);
    } catch (e) {
      _addLog('❌ Error opening $settingsType settings: $e');
    }
  }

  Future<void> _recheckPermission(String permissionType) async {
    if (!kIsWeb) return;

    try {
      PermissionStatus permissionStatus;
      switch (permissionType) {
        case 'camera':
          permissionStatus = await _permissionMaster.checkPermissionStatus(
            PermissionType.camera.value,
          );
          break;
        case 'microphone':
          permissionStatus = await _permissionMaster.checkPermissionStatus(
            PermissionType.microphone.value,
          );
          break;
        case 'location':
          permissionStatus = await _permissionMaster.checkPermissionStatus(
            PermissionType.fineLocation.value,
          );
          break;
        case 'notification':
          permissionStatus = await _permissionMaster.checkPermissionStatus(
            PermissionType.notifications.value,
          );
          break;
        default:
          return;
      }
      final status = permissionStatus.toString().split('.').last;

      setState(() {
        _permissionStatuses[permissionType] = status;
      });
      _addLog('🔄 $permissionType permission rechecked: $status');
    } catch (e) {
      _addLog('❌ Error rechecking $permissionType permission: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
        return Colors.red;
      case 'default':
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPermissionIcon(String permissionType) {
    switch (permissionType) {
      case 'camera':
        return Icons.camera_alt;
      case 'microphone':
        return Icons.mic;
      case 'location':
        return Icons.location_on;
      case 'notification':
        return Icons.notifications;
      default:
        return Icons.help;
    }
  }

  String _getPermissionDisplayName(String permissionType) {
    switch (permissionType) {
      case 'camera':
        return 'Camera';
      case 'microphone':
        return 'Microphone';
      case 'location':
        return 'Location';
      case 'notification':
        return 'Notification';
      default:
        return permissionType;
    }
  }

  Widget _buildPermissionCard(String permissionType) {
    final status = _permissionStatuses[permissionType] ?? 'Unknown';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getPermissionIcon(permissionType), size: 24),
                const SizedBox(width: 8),
                Text(
                  _getPermissionDisplayName(permissionType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _requestPermission(permissionType),
                    child: const Text('Request'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _openSettings(permissionType),
                    child: const Text('Settings'),
                  ),
                ),
              ],
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
        title: const Text('Web Permission Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkInitialPermissions,
            tooltip: 'Refresh Permissions',
          ),
        ],
      ),
      body: !kIsWeb
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Web Example',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This example is designed for Web platform only.\nPlease run this app on a browser to see the functionality.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Platform Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform: Web',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_platformVersion != null)
                        Text(
                          'Version: $_platformVersion',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),

                // Permission Status Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ..._permissionStatuses.keys.map(
                          (permissionType) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPermissionCard(permissionType),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Logs Section
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text(
                              'Logs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearLogs,
                              tooltip: 'Clear Logs',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            debugPrint(_logs[_logs.length - 1 - index]);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(_logs[_logs.length - 1 - index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
