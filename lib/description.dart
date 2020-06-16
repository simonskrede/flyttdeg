import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flyttdeg/takepicture.dart';
import 'package:flyttdeg/thanks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

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
  autofocus: true,
  maxLines: 40,
  style: const TextStyle(color: Colors.black, fontSize: 20.0),
  onChanged: changedText,
  decoration: new InputDecoration(
    /*icon: new Icon(
      Icons.insert_emoticon,
      color: Colors.black,
    ),*/
    border: InputBorder.none,
    hintText: "Beskriv hvorfor denne bør flytte seg ...",
    hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 20.0),
    contentPadding:
        const EdgeInsets.only(top: 40.0, right: 40.0, bottom: 40.0, left: 40.0),
  ),
);

Widget bodySection = new Expanded(
  child: new Container(
    padding: new EdgeInsets.all(8.0),
    color: Color(0xFFeeeeee),
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
              children: <Widget>[Text(message)],
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
    var file;
    if(widget.imagePath.isNotEmpty){
      file = await MultipartFile.fromFile(widget.imagePath, filename: "flyttdeg.jpg");
    } else {
      var imageData = (await rootBundle.load('packages/flyttdeg/assets/images/picture.jpg')).buffer.asUint8List();
      file = MultipartFile.fromBytes(imageData, filename: "flyttdeg.png");
    }

    var formData = FormData.fromMap({
      "position": widget.position.latitude.toString() +
          "," +
          widget.position.longitude.toString(),
      "description": lastTextValue,
      "file": file,
    });
    Dio dio = new Dio();

    try {
      await dio.post("https://flyttdeg.no/flyttdeg", data: formData);
    } on DioError catch (e) {
      await _showMyDialog(
          'Noe gikk galt, flytting er tilsynelatende vanskelig i dag :-|');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThanksScreen(),
      ),
    );
  }
}

var lastTextValue = "";

void changedText(String value) {
  lastTextValue = value;
}
