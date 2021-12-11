import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flyttdeg/persistent_buttons.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'displaymap.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? controller;

  Future<void>? _initializeControllerFuture;

  late List<CameraDescription> cameras;

  bool _isReady = false;

  @override
  void didUpdateWidget(TakePictureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller!.initialize();
  }

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      if (cameras.isEmpty) {
        print("Empty cameras");
        return;
      }

      controller = new CameraController(cameras[0], ResolutionPreset.medium,
          enableAudio: false);
      await controller!.initialize();
    } on CameraException catch (_) {
      print(_);
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller!.dispose();
    super.dispose();
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
          if (controller == null || !controller!.value.isInitialized) {
            return //Center(child: CircularProgressIndicator());
                Image(image: AssetImage("assets/images/picture.jpg"));
          } else {
            return CameraPreview(controller!);
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
      if (cameras.isNotEmpty) {
        // Ensure that the camera is initialized.
        await _initializeControllerFuture;

        // Attempt to take a picture and log where it's been saved.
        XFile picture = await controller!.takePicture();
        savedPath = picture.path;
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
