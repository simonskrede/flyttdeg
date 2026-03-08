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
      appBar: AppBar(
        title: const Text("Takk"),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Takk! Rapporten din vil bli vurdert før eventuell videresending til ${region?.capitalize() ?? "din"} kommune, som forhåpentligvis sørger for flytting!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      persistentFooterButtons:
          getFooterButtons("Mer flytting?", _flyttMer, context),
    );
  }

  void _flyttMer() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const TakePictureScreen(),
      ),
      (route) => false,
    );
  }
}
