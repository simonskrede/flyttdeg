import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class QuickDescription {
  late String displayValue;
  late String contentValue;
  late List<QuickDescription> children;

  QuickDescription(String displayValue, String contentValue,
      List<QuickDescription> children) {
    this.displayValue = displayValue;
    this.contentValue = contentValue;
    this.children = children;
  }
}

class QuickDescribe extends StatefulWidget {
  final TextEditingController controller;

  const QuickDescribe(
      {Key? key,
        required this.controller})
      : super(key: key);

  @override
  QuickDescribeState createState() => QuickDescribeState();
}

class QuickDescribeState extends State<QuickDescribe> {
  List<QuickDescription> topDescriptions = [];

  List<QuickDescription> currentDescriptions = [];

  QuickDescribeState() {
    topDescriptions
        .add(QuickDescription("Stans forbudt...", "All stans forbudt", [
      QuickDescription("i sykkelfelt", "i sykkelfelt", []),
      QuickDescription("på fortau", "på fortau", []),
      QuickDescription("i gangfelt", "i gangfelt", []),
      QuickDescription("på G/S-vei", "på gang- eller sykkelvei", []),
      QuickDescription("nært kryss", "nærmere enn 5 meter fra veikryss", [])
    ]));
    topDescriptions.add(QuickDescription("P-forbudt...", "Parkering forbudt", [
      QuickDescription("pga. skilting", "pga. skilting", []),
      QuickDescription("foran utkjørsel", "foran utkjørsel", []),
      QuickDescription("i gågate", "i gågate", []),
    ]));
    topDescriptions.add(QuickDescription("Er'e mulig...", "Er'e mulig", []));

    currentDescriptions = topDescriptions;
  }

  @override
  Widget build(BuildContext context) {
    List<PlatformTextButton> buttons = [];
    currentDescriptions.forEach((element) {
      buttons.add(PlatformTextButton(
          child: Text(element.displayValue), onPressed: () {
        String newText = "";
        if(widget.controller.value.text.isNotEmpty){
          newText = widget.controller.value.text + " ";
        }
        newText += element.contentValue;
        widget.controller.text = newText;
        if(element.children.length > 0) {
          setState(() {
            currentDescriptions = element.children;
          });
        }
        widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
      }));
    });
    return Wrap(children:
      buttons
    );
  }
}
