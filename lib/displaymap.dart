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
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _initialPosition;
  LatLng? _lastMapPosition;
  double _lastZoom = 18;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _lastMapPosition = _initialPosition;
        });
      }
    } catch (e) {
      print("Error determining position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double mapWidth = MediaQuery.of(context).size.width;
    double mapHeight = MediaQuery.of(context).size.height - 70;
    double iconSize = 40.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hvor skjedde det?"),
        backgroundColor: Colors.black,
      ),
      body: _initialPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  zoomGesturesEnabled: true,
                  onCameraMove: (CameraPosition position) {
                    _lastMapPosition = position.target;
                    _lastZoom = position.zoom;
                  },
                  myLocationEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: (mapHeight - iconSize) / 2 - 40, // Adjust for AppBar
                  child: Icon(Icons.person_pin_circle, size: iconSize, color: Colors.red),
                )
              ],
            ),
      persistentFooterButtons:
          getFooterButtons("Flytt deg!", _savePosition, context),
    );
  }

  void _savePosition() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescriptionScreen(
            position: _lastMapPosition,
            zoom: _lastZoom,
            imagePath: widget.imagePath),
      ),
    );
  }
}
