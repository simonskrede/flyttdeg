import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flyttdeg/persistent_buttons.dart';

import 'displaymap.dart';
import 'globals.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
        _isCameraInitialized = false;
      });
    }

    try {
      await cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = controller!.value.isInitialized;
        });
      }
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (cameras != null && cameras!.isNotEmpty) {
      onNewCameraSelected(cameras![0]);
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (region == null) {
        showTestAlertDialog();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                SizedBox.expand(child: CameraPreview(controller!)),
                if (_isTakingPicture)
                  const Center(child: CircularProgressIndicator()),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      persistentFooterButtons:
          getFooterButtons("Flytt deg!", _isTakingPicture ? null : _takePicture, context),
    );
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      XFile picture = await controller!.takePicture();
      
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayMapScreen(imagePath: picture.path),
        ),
      );
    } catch (e) {
      print("Error taking picture: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  void showTestAlertDialog() async {
    Widget okButton = TextButton(
      child: const Text("Ok"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Ikke støttet posisjon"),
      content: const Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Text(
            "Flytt deg er ikke tilgjengelig for din posisjon.\nTa gjerne kontakt med flyttdeg@flyttdeg.no om du ønsker å bidra til å utvide støtten til ditt område.\nDu kan likevel teste Flytt deg, men din melding vil ikke bli lagret eller videresendt.",
          ),
        ),
      ),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
