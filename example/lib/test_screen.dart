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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20.0,
          children: [
            Text("$platformVersion", style: TextStyle(fontSize: 24.0)),
            ElevatedButton(
              onPressed: () async {
                String version = (await permissionMaster.getPlatformVersion())!;
                setState(() {
                  platformVersion = version;
                });
                debugPrint(platformVersion);
              },
              child: Text("Get platform version"),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.deepPurpleAccent,
                      height: 400,
                      width: double.infinity,
                      child: Column(
                        spacing: 20.0,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await permissionMaster.grantedRequestPermission(
                                permission: PermissionType.camera,
                              );
                            },
                            child: Text("GRANTED"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await permissionMaster.denyRequestPermission(
                                permission: PermissionType.camera,
                              );
                              debugPrint("DENIED");
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Text("Denied"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text("Permission"),
            ),
            ElevatedButton(
              onPressed: () async {
                await permissionMaster.openAppSettingsDirectly();
                debugPrint("App settings opened");
              },
              child: Text("Open App Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
