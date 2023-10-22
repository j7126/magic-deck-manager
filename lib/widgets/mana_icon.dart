import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManaIcon extends StatefulWidget {
  const ManaIcon({super.key, required this.color});

  final String color;

  @override
  State<ManaIcon> createState() => _ManaIconState();
}

class _ManaIconState extends State<ManaIcon> {
  late String path;
  bool? exists;

  void setup() async {
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

  @override
  void initState() {
    path = 'assets/mana-icons/${widget.color.replaceAll('/', '')}.svg';
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
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
