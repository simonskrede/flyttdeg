import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

getFooterButtons(String text, Function() takePicture, BuildContext context) {
  return [
    PlatformIconButton(icon: context.widget),
    PlatformElevatedButton(child: PlatformText(text), onPressed: takePicture)
  ];
}
