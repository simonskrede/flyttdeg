import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'globals.dart';
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

  bool grantedAll = true;
  if (await Permission.camera.isGranted) {
    cameras = await availableCameras();
  } else {
    grantedAll = false;
  }

  if (await Permission.locationWhenInUse.isDenied) {
    grantedAll = false;
  }

  if(grantedAll) {
    try {
      final position = await Geolocator.getCurrentPosition();

      String url =
          "https://flyttdeg.no/location?latitude=${position
          .latitude}&longitude=${position.longitude}";

      final response = await new Dio().get(
        url,
      );

      Map responseData = response.data;
      region = responseData["region"];
      if (region == "null") {
        region = null;
      }
    } on DioError {
      region = null;
    }
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
      home: grantedAll && region != null
          ? TakePictureScreen()
          : Scaffold(
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                        !grantedAll
                            ? "Flyttdeg trenger tilgang til kamera og posisjon - skru dem på i innstillingene og start appen på nytt for å bruke den."
                            : "Flytt deg er ikke tilgjengelig for din posisjon. Ta gjerne kontakt med flyttdeg@flyttdeg.no om du ønsker å bidra til å utvide støtten til ditt område.",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2)
                  ])),
              persistentFooterButtons: !grantedAll
                  ? [
                      TextButton(
                          child: Text("Åpne innstillinger"),
                          onPressed: () => openAppSettings())
                    ]
                  : [])));
}
