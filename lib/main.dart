import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'takepicture.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.

  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.locationWhenInUse,
  ].request();

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(),
    ),
  );
}
