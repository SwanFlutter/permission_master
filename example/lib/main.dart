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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Permission Plugin Example'),
        ),
        body: Center(
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
            ],
          ),
        ),
      ),
    );
  }
}
