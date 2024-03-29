import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  if (grantedAll) {
    try {
      final position = await Geolocator.getCurrentPosition();

      String url =
          "https://flyttdeg.no/location?latitude=${position.latitude}&longitude=${position.longitude}";

      Dio dio = new Dio();
      dio.options.connectTimeout = Duration(seconds: 5);

      final response = await dio.get(url);

      Map responseData = response.data;
      region = responseData["region"];
      if (region == "null") {
        region = null;
      }
    } on DioException catch (e) {
      region = null;
    }
  }

  if (Platform.isAndroid) {
    await GoogleMapsFlutterAndroid()
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }

  await SentryFlutter.init((options) {
    options.dsn =
        'https://642645f4fb6e4d48afae5f52e783a87d@o1314118.ingest.sentry.io/6564954';
  },
      appRunner: () => runApp(PlatformApp(
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
                      persistentFooterButtons: !grantedAll
                          ? [
                              TextButton(
                                  child: Text("Åpne innstillinger"),
                                  onPressed: () => openAppSettings())
                            ]
                          : []))));
}
