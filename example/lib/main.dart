// ignore_for_file: unreachable_switch_default, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_master/permission_master.dart';
import 'package:permission_master_example/linux_example_screen.dart';
import 'package:permission_master_example/test_screen.dart';
import 'package:permission_master_example/web_example_screen.dart';

import 'windows_example_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Master Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: kIsWeb
          ? const WebExampleScreen()
          : Platform.isWindows
          ? const WindowsExampleScreen()
          : Platform.isMacOS
          ? const MacOSIOSExampleScreen()
          : Platform.isLinux
          ? const LinuxExampleScreen()
          : Platform.isIOS
          ? const MacOSIOSExampleScreen()
          : const PermissionDemoPage(),
    );
  }
}

/// Enhanced example screen specifically designed for macOS and iOS
/// Showcases all available permissions with modern UI and comprehensive testing
class MacOSIOSExampleScreen extends StatefulWidget {
  const MacOSIOSExampleScreen({super.key});

  @override
  State<MacOSIOSExampleScreen> createState() => _MacOSIOSExampleScreenState();
}

class _MacOSIOSExampleScreenState extends State<MacOSIOSExampleScreen>
    with TickerProviderStateMixin {
  final PermissionMaster _permissionMaster = PermissionMaster();
  final Map<String, PermissionStatus> _permissionStatus = {};
  final Map<String, int> _permissionAttempts = {};
  final GetStorageBridge _storage = GetStorageBridge();

  late TabController _tabController;
  bool _isLoading = false;
  String _platformVersion = 'Unknown';

  // Permission categories for better organization
  final List<PermissionGroup> _permissionGroups = [
    PermissionGroup(
      title: 'Media & Camera',
      icon: Icons.camera_alt,
      permissions: [
        PermissionItem(
          type: PermissionType.camera,
          title: 'Camera',
          description: 'Access camera for photos and video calls',
          icon: Icons.camera_alt,
          color: Colors.blue,
        ),
        PermissionItem(
          type: PermissionType.microphone,
          title: 'Microphone',
          description: 'Record audio for voice messages and calls',
          icon: Icons.mic,
          color: Colors.red,
        ),
        PermissionItem(
          type: PermissionType.readStorage,
          title: 'Photo Library',
          description: 'Access photos and media files',
          icon: Icons.photo_library,
          color: Colors.purple,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Location & Motion',
      icon: Icons.location_on,
      permissions: [
        PermissionItem(
          type: PermissionType.fineLocation,
          title: 'Location',
          description: 'Access precise location for maps and navigation',
          icon: Icons.location_on,
          color: Colors.green,
        ),
        PermissionItem(
          type: PermissionType.activityRecognition,
          title: 'Motion & Fitness',
          description: 'Track physical activity and motion data',
          icon: Icons.directions_run,
          color: Colors.orange,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Communication',
      icon: Icons.contacts,
      permissions: [
        PermissionItem(
          type: PermissionType.contacts,
          title: 'Contacts',
          description: 'Access your contacts for easy sharing',
          icon: Icons.contacts,
          color: Colors.teal,
        ),
        PermissionItem(
          type: PermissionType.notifications,
          title: 'Notifications',
          description: 'Send you important notifications',
          icon: Icons.notifications,
          color: Colors.amber,
        ),
        PermissionItem(
          type: PermissionType.calendar,
          title: 'Calendar',
          description: 'Access calendar events and create reminders',
          icon: Icons.calendar_today,
          color: Colors.indigo,
        ),
      ],
    ),
    PermissionGroup(
      title: 'Connectivity',
      icon: Icons.bluetooth,
      permissions: [
        PermissionItem(
          type: PermissionType.bluetooth,
          title: 'Bluetooth',
          description: 'Connect to Bluetooth devices',
          icon: Icons.bluetooth,
          color: Colors.cyan,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionMaster.setContext(context);
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    try {
      // Get platform version
      final version = await _permissionMaster.getPlatformVersion();
      setState(() => _platformVersion = version);

      // Load saved attempts
      await _loadPermissionAttempts();

      // Check initial permissions
      await _checkAllPermissions();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPermissionAttempts() async {
    try {
      final attempts = await _storage.read<Map<String, int>>(
        'permission_attempts',
        {},
      );
      setState(() {
        _permissionAttempts.addAll(attempts);
      });
    } catch (e) {
      debugPrint('Failed to load permission attempts: $e');
    }
  }

  Future<void> _savePermissionAttempts() async {
    try {
      await _storage.write('permission_attempts', _permissionAttempts);
    } catch (e) {
      debugPrint('Failed to save permission attempts: $e');
    }
  }

  Future<void> _checkAllPermissions() async {
    final allPermissions = _permissionGroups
        .expand((group) => group.permissions)
        .map((item) => item.type)
        .toList();

    try {
      final status = await _permissionMaster.checkMultiplePermissions(
        allPermissions,
      );
      if (mounted) {
        setState(() {
          _permissionStatus.addAll(status);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to check permissions: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);

    try {
      for (final group in _permissionGroups) {
        for (final permission in group.permissions) {
          await _requestSinglePermission(permission);
          // Small delay between requests for better UX
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to request all permissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestSinglePermission(PermissionItem permission) async {
    try {
      final attempts = _permissionAttempts[permission.type.value] ?? 0;

      // Update attempt count
      setState(() {
        _permissionAttempts[permission.type.value] = attempts + 1;
      });
      await _savePermissionAttempts();

      PermissionStatus result;

      // Request specific permission based on type
      switch (permission.type) {
        case PermissionType.camera:
          result = await _permissionMaster.requestCameraPermission();
          break;
        case PermissionType.microphone:
          result = await _permissionMaster.requestMicrophonePermission();
          break;
        case PermissionType.fineLocation:
          result = await _permissionMaster.requestLocationPermission();
          break;
        case PermissionType.readStorage:
          result = await _permissionMaster.requestStoragePermission();
          break;
        case PermissionType.contacts:
          result = await _permissionMaster.requestContactsPermission();
          break;
        case PermissionType.notifications:
          result = await _permissionMaster.requestNotificationPermission();
          break;
        case PermissionType.bluetooth:
          result = await _permissionMaster.requestBluetoothPermission();
          break;
        case PermissionType.calendar:
          result = await _permissionMaster.requestCalendarPermission();
          break;
        case PermissionType.activityRecognition:
          result = await _permissionMaster
              .requestActivityRecognitionPermission();
          break;
        default:
          result = PermissionStatus.error;
      }

      if (mounted) {
        setState(() {
          _permissionStatus[permission.type.value] = result;
        });

        _showPermissionResult(permission.title, result);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to request ${permission.title}: $e');
    }
  }

  void _showPermissionResult(String title, PermissionStatus result) {
    String message;
    Color backgroundColor;
    IconData icon;

    switch (result) {
      case PermissionStatus.granted:
        message = '$title permission granted!';
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case PermissionStatus.denied:
        message = '$title permission denied';
        backgroundColor = Colors.red;
        icon = Icons.cancel;
        break;
      case PermissionStatus.openSettings:
        message = '$title requires settings change';
        backgroundColor = Colors.orange;
        icon = Icons.settings;
        break;
      case PermissionStatus.error:
        message = 'Error with $title permission';
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      default:
        message = 'Unknown status for $title';
        backgroundColor = Colors.grey;
        icon = Icons.help;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = Platform.isMacOS ? 'macOS' : 'iOS';

    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Master - $platform'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAllPermissions,
            tooltip: 'Refresh permissions',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _permissionMaster.openAppSettings(),
            tooltip: 'Open app settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.security), text: 'Permissions'),
            Tab(icon: Icon(Icons.analytics), text: 'Status'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading permissions...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPermissionsTab(),
                _buildStatusTab(),
                _buildInfoTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _requestAllPermissions,
        icon: const Icon(Icons.security),
        label: const Text('Request All'),
        tooltip: 'Request all permissions',
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _permissionGroups.length,
      itemBuilder: (context, index) {
        final group = _permissionGroups[index];
        return _buildPermissionGroup(group);
      },
    );
  }

  Widget _buildPermissionGroup(PermissionGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(group.icon, color: Theme.of(context).primaryColor),
        title: Text(
          group.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        children: group.permissions
            .map((permission) => _buildPermissionTile(permission))
            .toList(),
      ),
    );
  }

  Widget _buildPermissionTile(PermissionItem permission) {
    final status = _permissionStatus[permission.type.value];
    final attempts = _permissionAttempts[permission.type.value] ?? 0;
    final isGranted = status == PermissionStatus.granted;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: permission.color.withOpacity(0.1),
        child: Icon(permission.icon, color: permission.color),
      ),
      title: Text(permission.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(permission.description),
          if (attempts > 0)
            Text(
              'Requested $attempts ${attempts == 1 ? 'time' : 'times'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != null)
            Icon(
              isGranted ? Icons.check_circle : Icons.cancel,
              color: isGranted ? Colors.green : Colors.red,
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _requestSinglePermission(permission),
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranted ? Colors.green : null,
              foregroundColor: isGranted ? Colors.white : null,
            ),
            child: Text(isGranted ? 'Granted' : 'Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    final allPermissions = _permissionGroups
        .expand((group) => group.permissions)
        .toList();

    final grantedCount = allPermissions
        .where(
          (p) => _permissionStatus[p.type.value] == PermissionStatus.granted,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permission Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: allPermissions.isEmpty
                        ? 0
                        : grantedCount / allPermissions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$grantedCount of ${allPermissions.length} permissions granted',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: allPermissions.length,
              itemBuilder: (context, index) {
                final permission = allPermissions[index];
                final status = _permissionStatus[permission.type.value];
                return _buildStatusTile(permission, status);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(PermissionItem permission, PermissionStatus? status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = Colors.green;
        statusText = 'Granted';
        statusIcon = Icons.check_circle;
        break;
      case PermissionStatus.denied:
        statusColor = Colors.red;
        statusText = 'Denied';
        statusIcon = Icons.cancel;
        break;
      case PermissionStatus.openSettings:
        statusColor = Colors.orange;
        statusText = 'Settings Required';
        statusIcon = Icons.settings;
        break;
      case PermissionStatus.error:
        statusColor = Colors.red;
        statusText = 'Error';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return ListTile(
      leading: Icon(permission.icon, color: permission.color),
      title: Text(permission.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Platform', Platform.operatingSystem),
                  _buildInfoRow('Version', _platformVersion),
                  _buildInfoRow('Plugin', 'Permission Master'),
                  _buildInfoRow('Updated', 'January 2026'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    'iOS 26 & macOS 26 Support',
                    'Full compatibility with latest OS versions',
                    Icons.system_update,
                  ),
                  _buildFeatureTile(
                    'New Calendar API',
                    'Updated to use latest EventKit APIs',
                    Icons.calendar_today,
                  ),
                  _buildFeatureTile(
                    'Enhanced Privacy',
                    'Respects user privacy preferences',
                    Icons.privacy_tip,
                  ),
                  _buildFeatureTile(
                    'Smart Requests',
                    'Intelligent permission request handling',
                    Icons.psychology,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(String title, String description, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(description),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Data models for better organization
class PermissionGroup {
  final String title;
  final IconData icon;
  final List<PermissionItem> permissions;

  PermissionGroup({
    required this.title,
    required this.icon,
    required this.permissions,
  });
}

class PermissionItem {
  final PermissionType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  PermissionItem({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
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

  Future<void> _checkSelectedPermissions() async {
    final permissions = [
      PermissionType.camera,
      PermissionType.fineLocation,
      PermissionType.microphone,
      PermissionType.contacts,
      PermissionType.notifications,
    ];
    final status = await _permissionMaster.checkMultiplePermissions(
      permissions,
    );
    if (!mounted) return;
    setState(() {
      _permissionStatus.addAll(status);
    });
  }

  Future<void> _requestSelectedPermissionsSequentially() async {
    try {
      final cam = await _permissionMaster.requestCameraPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus[PermissionType.camera.value] = cam;
        _permissionAttempts[PermissionType.camera.value] =
            (_permissionAttempts[PermissionType.camera.value] ?? 0) + 1;
      });

      final loc = await _permissionMaster.requestLocationPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus[PermissionType.fineLocation.value] = loc;
        _permissionAttempts[PermissionType.fineLocation.value] =
            (_permissionAttempts[PermissionType.fineLocation.value] ?? 0) + 1;
      });

      final mic = await _permissionMaster.requestMicrophonePermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus[PermissionType.microphone.value] = mic;
        _permissionAttempts[PermissionType.microphone.value] =
            (_permissionAttempts[PermissionType.microphone.value] ?? 0) + 1;
      });

      final con = await _permissionMaster.requestContactsPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus[PermissionType.contacts.value] = con;
        _permissionAttempts[PermissionType.contacts.value] =
            (_permissionAttempts[PermissionType.contacts.value] ?? 0) + 1;
      });

      final noti = await _permissionMaster.requestNotificationPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus[PermissionType.notifications.value] = noti;
        _permissionAttempts[PermissionType.notifications.value] =
            (_permissionAttempts[PermissionType.notifications.value] ?? 0) + 1;
      });

      await _savePermissionAttempts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting multiple permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Multiple permissions (example)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demo of checkMultiplePermissions and sequential requests',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _checkSelectedPermissions,
                          child: const Text('Check Multiple'),
                        ),
                        ElevatedButton(
                          onPressed: _requestSelectedPermissionsSequentially,
                          child: const Text('Request Multiple'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
