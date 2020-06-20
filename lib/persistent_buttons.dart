import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

getFooterButtons(String text, Function() takePicture) {
  return [
    PlatformButton(
        child: PlatformText(text),
        onPressed: takePicture,
        material: (_, __)  => MaterialRaisedButtonData(),
        cupertinoFilled: (_, __) => CupertinoFilledButtonData()
    )
  ];
}
