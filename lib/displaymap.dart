import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyttdeg/persistent_buttons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'description.dart';

class DisplayMapScreen extends StatefulWidget {
  final String imagePath;

  const DisplayMapScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  DisplayMapScreenState createState() => DisplayMapScreenState();
}

class DisplayMapScreenState extends State<DisplayMapScreen> {
  Completer<GoogleMapController>? controller;

  Geolocator geolocator = Geolocator();

  static LatLng? _initialPosition = new LatLng(59.9062988, 10.7878025);
  static LatLng? _lastMapPosition = _initialPosition;
  static double _initialZoom = 18;
  static double _lastZoom = _initialZoom;

  @override
  void initState() {
    super.initState();
    _initialPosition = null;
    print("established geolocator");

    _determinePosition();
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();

    print("done getting location");
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
            'Laster kart ...',
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
              target: _initialPosition!,
              zoom: _initialZoom,
            ),
            onMapCreated: (GoogleMapController _controller) {
              setState(() {
                if (controller != null) {
                  controller!.complete(_controller);
                }
              });
            },
            zoomGesturesEnabled: true,
            onCameraMove: (CameraPosition position) {
              _lastMapPosition = position.target;
              _lastZoom = position.zoom;
            },
            myLocationEnabled: true,
            compassEnabled: true,
            myLocationButtonEnabled: false,
          ),
        ]),
      ),
      persistentFooterButtons: getFooterButtons("Flytt deg!!", _savePosition),
    );
  }

  void _savePosition() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DescriptionScreen(
                position: _lastMapPosition,
                zoom: _lastZoom,
                imagePath: widget.imagePath),
      ),
    );
  }
}
