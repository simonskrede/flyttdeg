import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'displaymap.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {

  const TakePictureScreen({
    Key key,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();

}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController controller;

  Future<void> _initializeControllerFuture;

  List<CameraDescription> cameras;

  bool _isReady = false;

  @override
  void didUpdateWidget(TakePictureScreen oldWidget) {
    controller.initialize();
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
      controller = new CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
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
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return new Container();
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          print("test: " +  controller.value.isInitialized.toString());

          if (controller == null || !controller.value.isInitialized) {
            return Center(child: CircularProgressIndicator());
          } else {
            return CameraPreview(controller);
          }
        },
      ),
      persistentFooterButtons: [
        FlatButton(child: Text("Flytt deg!"), onPressed: _takePicture)
      ],
    );
  }

  _takePicture() async {
    // Take the PathPicture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await controller.takePicture(path);

      // If the picture was taken, display it on a new screen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayMapScreen(imagePath: path),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }
}
