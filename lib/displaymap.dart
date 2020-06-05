import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'description.dart';

class DisplayMapScreen extends StatefulWidget {
  final String imagePath;

  const DisplayMapScreen({
    Key key,
    @required this.imagePath,
  }) : super(key: key);

  @override
  DisplayMapScreenState createState() => DisplayMapScreenState();
}

class DisplayMapScreenState extends State<DisplayMapScreen> {
  Completer<GoogleMapController> controller;

  Geolocator geolocator = Geolocator();

  static LatLng _initialPosition = new LatLng(59.9062988, 10.7878025);
  static LatLng _lastMapPosition = _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition = null;
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _initialPosition == null
            ? Container(
                child: Center(
                  child: Text(
                    'loading map..',
                    style: TextStyle(
                        fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                  ),
                ),
              )
            : Container(
                child: Stack(children: <Widget>[
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.4746,
                    ),
                    onMapCreated: (GoogleMapController _controller) {
                      setState(() {
                        controller.complete(_controller);
                      });
                    },
                    zoomGesturesEnabled: true,
                    onCameraMove: (CameraPosition position) {
                      _lastMapPosition = position.target;
                    },
                    myLocationEnabled: true,
                    compassEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                ]),
              ),
        persistentFooterButtons: [
        FlatButton(child: Text("Flytt deg!!"), onPressed: _savePosition)
    ],
    );
  }

  void _savePosition() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescriptionScreen(
          position: _lastMapPosition,
          imagePath: widget.imagePath),
      ),
    );
  }
}
