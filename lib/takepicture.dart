import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flyttdeg/persistent_buttons.dart';

import 'displaymap.dart';
import 'globals.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? controller;

  bool _isCameraInitialized = false;

  int selectedCamera = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState: " + state.toString());
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    print("didChangeAppLifecycleState got past nullcheck");

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    print("Inside onNewCameraSelected");
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
        cameraDescription, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      print("Mounted = true, now setting controller value");
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    // Hide the status bar in Android
    //SystemChrome.setEnabledSystemUIOverlays([]);
    //getPermissionStatus();
    onNewCameraSelected(cameras![0]);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(controller!))
          : Center(child: CircularProgressIndicator()),
      persistentFooterButtons:
          getFooterButtons("Flytt deg!", _takePicture, context),
    );
  }

  _takePicture() async {
    // Take the PathPicture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      String savedPath;
      if (cameras != null) {
        // Ensure that the camera is initialized.
        try {
          // Attempt to take a picture and log where it's been saved.
          XFile picture = await controller!.takePicture();
          savedPath = picture.path;
        } catch (ex) {
          //Restart.restartApp();
          return;
        }

//        controller.pausePreview();
      } else {
        savedPath = "";
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayMapScreen(imagePath: savedPath),
        ),
      );
      // If the picture was taken, display it on a new screen.
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }
}
