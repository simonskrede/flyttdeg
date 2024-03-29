import 'package:flutter/material.dart';
import 'package:flyttdeg/persistent_buttons.dart';
import 'package:flyttdeg/takepicture.dart';
import 'package:flyttdeg/globals.dart';

class ThanksScreen extends StatefulWidget {
  const ThanksScreen({
    Key? key,
  }) : super(key: key);

  @override
  ThanksScreenState createState() => ThanksScreenState();
}

class ThanksScreenState extends State<ThanksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Center(
          child: Text(
              'Takk! Rapporten din vil bli vurdert av maskiner og mennesker før eventuell videresending til ${region!.capitalize()} kommune, som forhåpentligvis sørger for flytting!',
              textAlign: TextAlign.center,
              textScaleFactor: 2)),
      persistentFooterButtons:
          getFooterButtons("Mer flytting?", _flyttMer, context),
    );
  }

  void _flyttMer() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(),
      ),
    );
  }
}
