import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_master/permission_master.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _cameraPermissionStatus = 'Unknown';
  String _locationPermissionStatus = 'Unknown';
  String _microphonePermissionStatus = 'Unknown';
  String _photosPermissionStatus = 'Unknown';
  String _bluetoothPermissionStatus = 'Unknown';
  String _wifiPermissionStatus = 'Unknown';
  String _proximitySensorPermissionStatus = 'Unknown';
  String _contactsPermissionStatus = 'Unknown';

  final _permissionMasterPlugin = PermissionMaster();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Initializing platform version.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _permissionMasterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // درخواست مجوز دوربین
  Future<void> requestCameraPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestCameraPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _cameraPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // درخواست مجوز لوکیشن
  Future<void> requestLocationPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestLocationPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _locationPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request microphone permission
  Future<void> requestMicrophonePermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestMicrophonePermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _microphonePermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request permission to access photos
  Future<void> requestPhotosPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestPhotosPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _photosPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request Bluetooth permission
  Future<void> requestBluetoothPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestBluetoothPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _bluetoothPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request WiFi permission
  Future<void> requestWiFiPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestWiFiPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _wifiPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request proximity sensor permission
  Future<void> requestProximitySensorPermission() async {
    bool isGranted;
    try {
      isGranted =
          await _permissionMasterPlugin.requestProximitySensorPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _proximitySensorPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  // Request contacts permission
  Future<void> requestContactsPermission() async {
    bool isGranted;
    try {
      isGranted = await _permissionMasterPlugin.requestContactsPermission();
    } catch (e) {
      isGranted = false;
    }

    setState(() {
      _contactsPermissionStatus = isGranted ? 'Granted' : 'Denied';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Permission Plugin Example'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Running on: $_platformVersion\n'),
                ElevatedButton(
                  onPressed: requestCameraPermission,
                  child: const Text('Request Camera Permission'),
                ),
                Text('Camera Permission: $_cameraPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestLocationPermission,
                  child: const Text('Request Location Permission'),
                ),
                Text('Location Permission: $_locationPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestMicrophonePermission,
                  child: const Text('Request Microphone Permission'),
                ),
                Text('Microphone Permission: $_microphonePermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestPhotosPermission,
                  child: const Text('Request Photos Permission'),
                ),
                Text('Photos Permission: $_photosPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestBluetoothPermission,
                  child: const Text('Request Bluetooth Permission'),
                ),
                Text('Bluetooth Permission: $_bluetoothPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestWiFiPermission,
                  child: const Text('Request WiFi Permission'),
                ),
                Text('WiFi Permission: $_wifiPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestProximitySensorPermission,
                  child: const Text('Request Proximity Sensor Permission'),
                ),
                Text(
                    'Proximity Sensor Permission: $_proximitySensorPermissionStatus\n'),
                ElevatedButton(
                  onPressed: requestContactsPermission,
                  child: const Text('Request Contacts Permission'),
                ),
                Text('Contacts Permission: $_contactsPermissionStatus\n'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
