import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

getFooterButtons(String text, Function() takePicture, BuildContext context) {
  return [
    PlatformIconButton(
        materialIcon: Icon(Icons.info),
        cupertinoIcon: Icon(CupertinoIcons.info),
        onPressed: () {
          showAlertDialog(context);
        }),
    PlatformElevatedButton(child: PlatformText(text), onPressed: takePicture)
  ];
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Ok"),
    onPressed: () => Navigator.pop(context),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Hva er Flytt deg?"),
    content: Text('Flytt deg lar deg enkelt bidra til økt fokus på bilster som tar seg til rette i sykkelfelt og '
        'andre steder de ikke har lov å parkere.\n\nSlik gjør du det:\n\n'
        '1. Ta et bilde som beskriver situasjonen på en god måte.\n\n'
        '2. Merk så nøyaktig du kan i kartet hvor feilparkeringen har skjedd.\n\n'
        '3. Skriv en kort tekst som beskriver situasjonen.\n\n'
        '4. Send inn og besøk gjerne nettsiden flyttdeg.no for mer informasjon og kule verktøy :-)'),
    actions: [
      okButton
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
