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
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await GoogleMapsFlutterAndroid()
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://642645f4fb6e4d48afae5f52e783a87d@o1314118.ingest.sentry.io/6564954';
    },
    appRunner: () => runApp(const FlyttDegApp()),
  );
}

class FlyttDegApp extends StatelessWidget {
  const FlyttDegApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('no', '')],
      home: const InitializationScreen(),
    );
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({Key? key}) : super(key: key);

  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  bool _isLoading = true;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();

    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;

    if (cameraGranted && locationGranted) {
      try {
        cameras = await availableCameras();
        
        final position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 5));

        String url =
            "https://flyttdeg.no/location?latitude=${position.latitude}&longitude=${position.longitude}";

        Dio dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);

        final response = await dio.get(url);

        Map responseData = response.data;
        region = responseData["region"];
        if (region == "null") {
          region = null;
        }
      } catch (e) {
        print("Initialization error: $e");
        region = null;
      }

      if (mounted) {
        setState(() {
          _permissionsGranted = true;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _permissionsGranted = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Laster Flytt deg..."),
            ],
          ),
        ),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Flyttdeg trenger tilgang til kamera og posisjon for å fungere.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                PlatformElevatedButton(
                  child: const Text("Åpne innstillinger"),
                  onPressed: () async {
                    await openAppSettings();
                    _initApp(); // Retry after returning from settings
                  },
                ),
                const SizedBox(height: 10),
                PlatformTextButton(
                  child: const Text("Prøv igjen"),
                  onPressed: () => _initApp(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const TakePictureScreen();
  }
}
