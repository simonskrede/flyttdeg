library globals;

import 'package:camera/camera.dart';

List<CameraDescription>? cameras;

String? region;

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
