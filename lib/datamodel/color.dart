import 'package:flutter/material.dart';

enum ManaColor {
  black(str: 'B'),
  green(str: 'G'),
  red(str: 'R'),
  blue(str: 'U'),
  white(str: 'W'),
  none(str: 'C');

  const ManaColor({
    required this.str,
  });

  final String str;

  static ManaColor fromStr(String str) {
    switch (str) {
      case 'B':
        return ManaColor.black;
      case 'G':
        return ManaColor.green;
      case 'R':
        return ManaColor.red;
      case 'U':
        return ManaColor.blue;
      case 'W':
        return ManaColor.white;
      default:
        return ManaColor.none;
    }
  }

  static Color getColor(ManaColor color, {int opacity = 255}) {
    switch (color) {
      case ManaColor.black:
        return Color.fromARGB(opacity, 179, 164, 159);
      case ManaColor.green:
        return Color.fromARGB(opacity, 148, 203, 169);
      case ManaColor.red:
        return Color.fromARGB(opacity, 255, 169, 138);
      case ManaColor.blue:
        return Color.fromARGB(opacity, 164, 216, 241);
      case ManaColor.white:
        return Color.fromARGB(opacity, 255, 255, 204);
      case ManaColor.none:
        return Colors.transparent;
    }
  }

  static String getString(dynamic color) {
    if (color is ManaColor) {
      return color.str;
    } else if (color is Set<ManaColor>) {
      return '{${color.map((e) => e.str).join('}{')}}';
    } else {
      return "";
    }
  }
}
