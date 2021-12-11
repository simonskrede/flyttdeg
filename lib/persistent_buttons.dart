import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

getFooterButtons(String text, Function() takePicture) {
  return [
    PlatformElevatedButton(child: PlatformText(text), onPressed: takePicture)
  ];
}
