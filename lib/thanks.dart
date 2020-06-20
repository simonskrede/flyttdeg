import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flyttdeg/persistent_buttons.dart';
import 'package:flyttdeg/takepicture.dart';

class ThanksScreen extends StatefulWidget {
  const ThanksScreen({
    Key key,
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
              'Takk, nå er det Bymiljøetaten som forhåpentligvis sørger for flytting!',
              textAlign: TextAlign.center,
              textScaleFactor: 2)),
      persistentFooterButtons: getFooterButtons("Flere som skal flytte seg?", _flyttMer),
    );
  }

  void _flyttMer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(),
      ),
    );
  }
}
