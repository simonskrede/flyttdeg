import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'globals.dart';

List<Widget> getFooterButtons(String text, Function()? onPressed, BuildContext context) {
  return [
    PlatformIconButton(
        materialIcon: const Icon(Icons.info_outline),
        cupertinoIcon: const Icon(CupertinoIcons.info),
        onPressed: () {
          showAboutFlyttDegDialog(context);
        }),
    PlatformElevatedButton(
      child: PlatformText(text),
      onPressed: onPressed,
      material: (_, __) => MaterialElevatedButtonData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
    )
  ];
}

void showAboutFlyttDegDialog(BuildContext context) {
  showPlatformDialog(
    context: context,
    builder: (_) => PlatformAlertDialog(
      title: const Text("Hva er Flytt deg?"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Flytt deg lar deg enkelt bidra til økt fokus på bilister som tar seg til rette i sykkelfelt og andre steder de ikke har lov å parkere.\n'),
            const Text('Slik gjør du det:'),
            const Text('1. Ta et bilde av situasjonen.'),
            const Text('2. Marker posisjonen i kartet.'),
            const Text('3. Skriv en kort beskrivelse.'),
            const Text('4. Send inn!\n'),
            Text('Din region: ${region?.capitalize() ?? "Ukjent"}'),
          ],
        ),
      ),
      actions: <Widget>[
        PlatformDialogAction(
          child: PlatformText("Ok"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

