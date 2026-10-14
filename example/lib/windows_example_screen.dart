// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';

/// Windows-specific example screen for demonstrating Windows permission handling
class WindowsExampleScreen extends StatefulWidget {
  const WindowsExampleScreen({super.key});

  @override
  State<WindowsExampleScreen> createState() => _WindowsExampleScreenState();
}

class _WindowsExampleScreenState extends State<WindowsExampleScreen> {
  final PermissionMaster _permissionMaster = PermissionMaster();
  String? _platformVersion;
  bool _isLoading = false;
  final List<String> _logs = [];
  final Map<String, String> _permissionStatuses = {
    'camera': 'Unknown',
    'microphone': 'Unknown',
    'location': 'Unknown',
    'notification': 'Unknown',
    'radios': 'Unknown',
    'voiceActivation': 'Unknown',
    'email': 'Unknown',
  };

  @override
  void initState() {
    super.initState();
    PermissionMaster.setContext(context);
    _initializeWindowsExample();
  }

  Future<void> _initializeWindowsExample() async {
    if (!Platform.isWindows) {
      _addLog('⚠️ This example is designed for Windows platform only');
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
    if (!Platform.isWindows) return;

    setState(() {
      _isLoading = true;
    });

    try {
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
    await _checkRadiosPermission();
    await _checkVoiceActivationPermission();
    await _checkEmailPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await _permissionMaster.checkCameraPermissionWindows();
      setState(() {
        _permissionStatuses['camera'] = status;
      });
      _addLog('📷 Camera permission: $status');
    } catch (e) {
      _addLog('❌ Error checking camera permission: $e');
    }
  }

  Future<void> _checkMicrophonePermission() async {
    try {
      final status = await _permissionMaster.checkMicrophonePermissionWindows();
      setState(() {
        _permissionStatuses['microphone'] = status;
      });
      _addLog('🎤 Microphone permission: $status');
    } catch (e) {
      _addLog('❌ Error checking microphone permission: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      final status = await _permissionMaster.checkLocationPermissionWindows();
      setState(() {
        _permissionStatuses['location'] = status;
      });
      _addLog('📍 Location permission: $status');
    } catch (e) {
      _addLog('❌ Error checking location permission: $e');
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final status = await _permissionMaster
          .checkNotificationPermissionWindows();
      setState(() {
        _permissionStatuses['notification'] = status;
      });
      _addLog('🔔 Notification permission: $status');
    } catch (e) {
      _addLog('❌ Error checking notification permission: $e');
    }
  }

  Future<void> _checkRadiosPermission() async {
    try {
      final status = await _permissionMaster.checkRadiosPermissionWindows();
      setState(() {
        _permissionStatuses['radios'] = status;
      });
      _addLog('📡 Radios permission: $status');
    } catch (e) {
      _addLog('❌ Error checking radios permission: $e');
    }
  }

  Future<void> _checkVoiceActivationPermission() async {
    try {
      final status = await _permissionMaster
          .checkVoiceActivationPermissionWindows();
      setState(() {
        _permissionStatuses['voiceActivation'] = status;
      });
      _addLog('🗣️ Voice Activation permission: $status');
    } catch (e) {
      _addLog('❌ Error checking voice activation permission: $e');
    }
  }

  Future<void> _checkEmailPermission() async {
    try {
      final status = await _permissionMaster.checkEmailPermissionWindows();
      setState(() {
        _permissionStatuses['email'] = status;
      });
      _addLog('📧 Email permission: $status');
    } catch (e) {
      _addLog('❌ Error checking email permission: $e');
    }
  }

  Future<void> _requestPermission(String permissionType) async {
    if (!Platform.isWindows) {
      _addLog(
        '⚠️ $permissionType permission request is only available on Windows',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('🔄 Requesting $permissionType permission...');
      String result;

      switch (permissionType) {
        case 'camera':
          result = await _permissionMaster.requestCameraPermissionWindows();
          break;
        case 'microphone':
          result = await _permissionMaster.requestMicrophonePermissionWindows();
          break;
        case 'location':
          result = await _permissionMaster.requestLocationPermissionWindows();
          break;
        case 'notification':
          result = await _permissionMaster
              .requestNotificationPermissionWindows();
          break;
        case 'radios':
          result = await _permissionMaster.requestRadiosPermissionWindows();
          break;
        case 'voiceActivation':
          result = await _permissionMaster
              .requestVoiceActivationPermissionWindows();
          break;
        case 'email':
          result = await _permissionMaster.requestEmailPermissionWindows();
          break;
        default:
          result = 'unknown';
      }

      setState(() {
        _permissionStatuses[permissionType] = result;
      });
      _addLog('✅ $permissionType Permission Result: $result');

      if (result == 'denied' || result == 'restricted') {
        _addLog(
          '💡 Tip: You can open $permissionType settings to manually grant permission',
        );
      }

      // If Windows opened settings for location, automatically re-check a few times
      if (permissionType == 'location' && result == 'requested') {
        _addLog('⏳ Waiting for you to change Windows Location setting...');
        _pollLocationAfterSettings();
      }
    } catch (e) {
      _addLog('❌ Error requesting $permissionType permission: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Poll location status for a short period after opening settings
  void _pollLocationAfterSettings() {
    int attempts = 0;
    const maxAttempts = 6; // ~12 seconds total
    final timer = Timer.periodic(const Duration(seconds: 2), (t) async {
      attempts++;
      final status = await _permissionMaster.checkLocationPermissionWindows();
      _addLog('🔁 Re-check location status: $status');
      setState(() {
        _permissionStatuses['location'] = status;
      });
      if (status == 'granted' || attempts >= maxAttempts) {
        if (status == 'granted') {
          _addLog('✅ Location permission granted on Windows');
        } else {
          _addLog(
            '⌛️ Stopped waiting. You can tap "Check" to try again after changing settings.',
          );
        }
        t.cancel();
      }
    });
  }

  Future<void> _openSettings(String settingsType) async {
    if (!Platform.isWindows) {
      _addLog('⚠️ Opening $settingsType settings is only available on Windows');
      return;
    }

    try {
      _addLog('🔧 Opening Windows $settingsType settings...');

      switch (settingsType) {
        case 'camera':
          await _permissionMaster.openCameraSettingsWindows();
          break;
        case 'microphone':
          await _permissionMaster.openMicrophoneSettingsWindows();
          break;
        case 'location':
          await _permissionMaster.openLocationSettingsWindows();
          break;
        case 'notification':
          await _permissionMaster.openNotificationSettingsWindows();
          break;
        case 'radios':
          await _permissionMaster.openRadiosSettingsWindows();
          break;
        case 'speech':
          await _permissionMaster.openSpeechSettingsWindows();
          break;
        case 'app':
          await _permissionMaster.openAppSettingsWindows();
          break;
      }

      _addLog('✅ $settingsType settings opened successfully');

      // Wait a bit and then recheck permission
      await Future.delayed(const Duration(seconds: 2));
      if (settingsType != 'app' && settingsType != 'speech') {
        await _recheckPermission(settingsType);
      }
    } catch (e) {
      _addLog('❌ Error opening $settingsType settings: $e');
    }
  }

  Future<void> _recheckPermission(String permissionType) async {
    if (!Platform.isWindows) return;

    try {
      String status;
      switch (permissionType) {
        case 'camera':
          status = await _permissionMaster.checkCameraPermissionWindows();
          break;
        case 'microphone':
          status = await _permissionMaster.checkMicrophonePermissionWindows();
          break;
        case 'location':
          status = await _permissionMaster.checkLocationPermissionWindows();
          break;
        case 'notification':
          status = await _permissionMaster.checkNotificationPermissionWindows();
          break;
        case 'radios':
          status = await _permissionMaster.checkRadiosPermissionWindows();
          break;
        case 'voiceActivation':
          status = await _permissionMaster
              .checkVoiceActivationPermissionWindows();
          break;
        case 'email':
          status = await _permissionMaster.checkEmailPermissionWindows();
          break;
        default:
          return;
      }

      setState(() {
        _permissionStatuses[permissionType] = status;
      });
      _addLog('🔄 $permissionType permission rechecked: $status');
    } catch (e) {
      _addLog('❌ Error rechecking $permissionType permission: $e');
    }
  }

  Future<void> _checkGenericPermission() async {
    if (!Platform.isWindows) {
      _addLog('⚠️ Generic permission check is only available on Windows');
      return;
    }

    try {
      _addLog('🔍 Checking generic camera permission...');
      final result = await _permissionMaster.checkPermissionStatusWindows(
        'camera',
      );
      _addLog('🔍 Generic Camera Permission Status: $result');

      _addLog('🔍 Checking generic microphone permission...');
      final micResult = await _permissionMaster.checkPermissionStatusWindows(
        'microphone',
      );
      _addLog('🔍 Generic Microphone Permission Status: $micResult');
    } catch (e) {
      _addLog('❌ Error checking generic permission: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logs.length > 50) {
        setState(() {
          _logs.removeAt(0);
        });
      }
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
      case 'allowed':
        return Colors.green;
      case 'denied':
      case 'restricted':
        return Colors.red;
      case 'unknown':
      case 'not_determined':
      case 'not_available':
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
      case 'radios':
        return Icons.radio;
      case 'voiceActivation':
        return Icons.record_voice_over;
      case 'email':
        return Icons.email;
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
      case 'radios':
        return 'Radios';
      case 'voiceActivation':
        return 'Voice Activation';
      case 'email':
        return 'Email';
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
        title: const Text('Windows Permission Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkInitialPermissions,
            tooltip: 'Refresh Permissions',
          ),
        ],
      ),
      body: !Platform.isWindows
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Windows Example',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This example is designed for Windows platform only.\nPlease run this app on Windows to see the functionality.',
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
                        'Platform: Windows',
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
                        // Permission Cards Grid
                        ..._permissionStatuses.keys.map(
                          (permissionType) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPermissionCard(permissionType),
                          ),
                        ),

                        // Additional Actions Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.settings, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Additional Actions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : _checkGenericPermission,
                                      icon: const Icon(Icons.search, size: 16),
                                      label: const Text('Check Generic'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _openSettings('speech'),
                                      icon: const Icon(
                                        Icons.record_voice_over,
                                        size: 16,
                                      ),
                                      label: const Text('Speech Settings'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _openSettings('app'),
                                      icon: const Icon(
                                        Icons.settings,
                                        size: 16,
                                      ),
                                      label: const Text('App Settings'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Logs Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.list_alt, size: 24),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Activity Logs',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _clearLogs,
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _logs.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No logs yet. Try requesting permissions!',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _logs.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              child: SelectableText(
                                                _logs[index],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isLoading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(),
            )
          : null,
    );
  }
}
