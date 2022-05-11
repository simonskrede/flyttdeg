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

  bool grantedAll = true;
  if (await Permission.camera.isGranted) {
    cameras = await availableCameras();
  } else {
    grantedAll = false;
  }

  if (await Permission.locationWhenInUse.isDenied) {
    grantedAll = false;
  }

  runApp(PlatformApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('no', '')
      ],
      home: grantedAll
          ? TakePictureScreen()
          : Scaffold(
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                        "Flyttdeg trenger tilgang til kamera og posisjon - skru dem på i innstillingene og start appen på nytt for å bruke den.",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2)
                  ])),
              persistentFooterButtons: [
                  TextButton(
                      child: Text("Åpne innstillinger"),
                      onPressed: () => openAppSettings())
                ])));
}
