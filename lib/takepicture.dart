import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flyttdeg/persistent_buttons.dart';

//import 'package:restart_app/restart_app.dart';

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
  late CameraController controller;
  late CameraPreview preview;
  Future<void>? _initializeControllerFuture;

  int selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera(selectedCamera);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }

  initializeCamera(int cameraIndex) async {
    controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras![cameraIndex],
      // Define the resolution to use.
      ResolutionPreset.high
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    //if (!_isReady) return new Container();
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
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
        await _initializeControllerFuture;

        try {
          // Attempt to take a picture and log where it's been saved.
          XFile picture = await controller!.takePicture();
          savedPath = picture.path;
        } catch (ex) {
          //Restart.restartApp();
          return;
        }

        controller.pausePreview();
      } else {
        savedPath = "";
      }

      Navigator.push(
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
