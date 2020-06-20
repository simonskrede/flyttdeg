import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
    print("established geolocator");

    _getUserLocation();
  }

  void _getUserLocation() async {
    /*print("checking permission");

    await Geolocator().checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse);

    print("getting location");

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, locationPermissionLevel: GeolocationPermission.locationWhenInUse);*/

    var channel = MethodChannel('flutter.baseflow.com/geolocator/methods');
    Map<String, dynamic> params = <String, dynamic>{
      'accuracy': LocationAccuracy.high.value,
      'distanceFilter': 0,
      'forceAndroidLocationManager': false, // <- choose what's best for you
      'timeInterval': 0,
    };
    Map<dynamic, dynamic> positionMap = await channel.invokeMethod(
      'getCurrentPosition',
      params,
    );

// Get the properties you need here. You may want to check if they exist first.
    double latitude = positionMap['latitude'];
    double longitude = positionMap['longitude'];

    print("done getting location");
    setState(() {
      _initialPosition = LatLng(latitude, longitude);
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
                      if(controller != null){
                        controller.complete(_controller);
                      }
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
        PlatformButton(child: Text("Flytt deg!!"), onPressed: _savePosition)
      ],
    );
  }

  void _savePosition() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescriptionScreen(
            position: _lastMapPosition, imagePath: widget.imagePath),
      ),
    );
  }
}
