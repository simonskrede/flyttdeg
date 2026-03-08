import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flyttdeg/persistent_buttons.dart';
import 'package:flyttdeg/quickdescribe.dart';
import 'package:flyttdeg/thanks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DescriptionScreen extends StatefulWidget {
  final String imagePath;
  final LatLng? position;
  final double zoom;

  const DescriptionScreen({
    Key? key,
    required this.imagePath,
    required this.position,
    required this.zoom,
  }) : super(key: key);

  @override
  DescriptionScreenState createState() => DescriptionScreenState();
}

class DescriptionScreenState extends State<DescriptionScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late QuickDescribe _quickDescribe;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _quickDescribe = QuickDescribe(controller: _textEditingController);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beskrivelse"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: const Color(0xFFeeeeee),
                child: PlatformTextField(
                  autofocus: true,
                  maxLines: 40,
                  style: const TextStyle(color: Colors.black, fontSize: 20.0),
                  controller: _textEditingController,
                  material: (_, __) => MaterialTextFieldData(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Beskriv hvorfor denne bør flytte seg ...",
                      hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 20.0),
                      contentPadding: EdgeInsets.all(40.0),
                    ),
                  ),
                  cupertino: (_, __) => CupertinoTextFieldData(
                    placeholder: "Beskriv hvorfor denne bør flytte seg ...",
                    placeholderStyle: const TextStyle(color: Color(0xFF666666), fontSize: 20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            _quickDescribe,
            if (_isSending)
              const LinearProgressIndicator(),
            ButtonBar(
              children: getFooterButtons(
                "Flytt deg!!!",
                _isSending ? null : _transmitInfo,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Flytter den seg?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message)],
            ),
          ),
          actions: <Widget>[
            PlatformTextButton(
              child: const Text('Sukk, ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _transmitInfo() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    dynamic file;
    try {
      if (widget.imagePath.isNotEmpty) {
        file = await MultipartFile.fromFile(widget.imagePath, filename: "flyttdeg.jpg");
      } else {
        var imageData = (await rootBundle.load('packages/flyttdeg/assets/images/picture.jpg'))
            .buffer
            .asUint8List();
        file = MultipartFile.fromBytes(imageData, filename: "flyttdeg.png");
      }

      var formData = FormData.fromMap({
        "position": "${widget.position!.latitude},${widget.position!.longitude}",
        "zoom": widget.zoom.toString(),
        "description": _textEditingController.text,
        "file": file,
      });

      BaseOptions options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      await Dio(options).post(
        "https://flyttdeg.no/flyttdeg",
        data: formData,
      );

      if (!mounted) return;

      // Clean up the file
      if (widget.imagePath.isNotEmpty) {
        var deleteFile = File(widget.imagePath);
        if (await deleteFile.exists()) {
          await deleteFile.delete();
        }
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ThanksScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Transmission error: $e");
      await _showErrorDialog('Noe gikk galt, flytting er tilsynelatende vanskelig i dag :-|');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}
