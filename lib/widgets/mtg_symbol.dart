import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MtgSymbol extends StatefulWidget {
  const MtgSymbol({super.key, required this.color});

  final String color;

  @override
  State<MtgSymbol> createState() => _MtgSymbolState();
}

class _MtgSymbolState extends State<MtgSymbol> {
  late String path;
  bool? exists;

  String get actualPath => 'assets/mana-icons/${widget.color.replaceAll('/', '')}.svg';

  void setup() async {
    if (exists == null) {
      try {
        await rootBundle.load(path);
        setState(() {
          exists = true;
        });
      } catch (_) {
        setState(() {
          exists = false;
        });
      }
    }
  }

  @override
  void initState() {
    path = 'assets/mana-icons/${widget.color.replaceAll('/', '')}.svg';
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    if (path != actualPath) {
      exists = null;
      path = actualPath;
      setup();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: exists == null
          ? Container()
          : exists == true
              ? SvgPicture.asset(path)
              : Text('{${widget.color}}'),
    );
  }
}
