import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flyttdeg/takepicture.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DescriptionScreen extends StatefulWidget {
  final String imagePath;
  final LatLng position;

  const DescriptionScreen(
      {Key key, @required this.imagePath, @required this.position})
      : super(key: key);

  @override
  DescriptionScreenState createState() => DescriptionScreenState();
}

TextField textField = new TextField(
  style: const TextStyle(
    color: Colors.black,
  ),
  onChanged: changedText,
  decoration: new InputDecoration(
    icon: new Icon(
      Icons.insert_emoticon,
      color: Colors.black,
    ),
    border: InputBorder.none,
    hintText: "Beskriv hvorfor denne bør flytte seg ...",
    hintStyle: const TextStyle(color: Colors.black, fontSize: 12.0),
    contentPadding: const EdgeInsets.only(
        top: 20.0, right: 5.0, bottom: 20.0, left: 30.0),
  ),
);

Widget bodySection = new Expanded(
  child: new Container(
    padding: new EdgeInsets.all(8.0),
    color: Colors.white70,
    child: textField,
  ),
);

class DescriptionScreenState extends State<DescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Padding(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: Column(
          // This makes each child fill the full width of the screen
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            bodySection,
            ButtonBar(children: [
              FlatButton(child: Text("Flytt deg!!!"), onPressed: _transmitInfo)
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Flytter den seg?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Sukk, ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _transmitInfo() async {
    var formData = FormData.fromMap({
      "position": widget.position.latitude.toString()+","+widget.position.longitude.toString(),
      "description": lastTextValue,
      "file": await MultipartFile.fromFile(widget.imagePath, filename: "flyttdeg.png"),
    });
    Dio dio = new Dio();

    try {
      await dio.post(
          "http://192.168.1.200:8099/flyttdeg", data: formData);
    } on DioError catch (e){
      await _showMyDialog('Noe gikk galt, flytting er tilsynelatende vanskelig i dag :-|');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(),
        ),
      );
      return;
    }

    await _showMyDialog('Melding om uhensiktsmessig plassering er sendt. Nå er flytting opp til Bymiljøetaten :-|');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(),
      ),
    );
  }
}

var lastTextValue = "";

void changedText(String value) {
  lastTextValue = value;
}
