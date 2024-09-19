# permission_master

``PermissionMaster'' is a Flutter plugin that allows you to manage and request different permissions on Android and iOS operating systems. This plugin is provided locally for both platforms and includes various methods to request access to the camera, location, microphone, and photos.

## Features

- Request access to the camera
- Location access request
- Request access to the microphone
- Request access to photos

## Installation

To use PermissionMaster in your Flutter project, just add it as a dependency to the pubspec.yaml file:

```yaml
dependencies:
  permission_master: ^0.0.1
```

```yaml
  dependencies:
 permission_master:
      git:
        url: https://github.com/SwanFlutter/permission_master.git
```

## Getting Started

## How to use


1. Import the plugin
First you need to import the plugin:

```dart

import 'package:permission_master/permission_master.dart';;

```
2. Access requests

- Request access to the camera
```dart

bool isCameraPermissionGranted = await PermissionMaster().requestCameraPermission();

```
- Request location access
```dart

bool isLocationPermissionGranted = await PermissionMaster().requestLocationPermission();

```

- Request access to the microphone

```dart

bool isMicrophonePermissionGranted = await PermissionMaster().requestMicrophonePermission();
```

- Request access to photos
```dart

bool isPhotosPermissionGranted = await PermissionMaster().requestPhotosPermission();

```

3. Display access status
You can use boolean return values ​​to display access status. For example, you can check the camera access status as follows:

```dart
if (isCameraPermissionGranted) {
  print('Camera permission is granted');
} else {
  print('Camera permission is not granted');
}
```

## example

```dart

import 'package:flutter/material.dart';
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
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    bool cameraPermission = await PermissionMaster().requestCameraPermission();
    setState(() {
      _isCameraPermissionGranted = cameraPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PermissionMaster Example'),
        ),
        body: Center(
          child: Text(
            'Camera permission granted: $_isCameraPermissionGranted',
          ),
        ),
      ),
    );
  }
}

```


## Additional information

If you have any issues, questions, or suggestions related to this package, please feel free to contact us at [swan.dev1993@gmail.com](mailto:swan.dev1993@gmail.com). We welcome your feedback and will do our best to address any problems or provide assistance.
For more information about this package, you can also visit our [GitHub repository](https://github.com/SwanFlutter/flutter_saver) where you can find additional resources, contribute to the package's development, and file issues or bug reports. We appreciate your contributions and feedback, and we aim to make this package as useful as possible for our users.
Thank you for using our package, and we look forward to hearing from you!

