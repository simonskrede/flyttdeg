import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'takepicture.dart';

import 'globals.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.

  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.locationWhenInUse,
  ].request();

  cameras = await availableCameras();

  runApp(
    PlatformApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('no', '')],
      home: TakePictureScreen(),
    ),
  );
}
