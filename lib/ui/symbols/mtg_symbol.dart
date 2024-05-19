import 'package:flutter/material.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';

class MtgSymbol extends StatelessWidget {
  const MtgSymbol({
    super.key,
    required this.symbol,
    this.fitted = true,
    this.margin = EdgeInsets.zero,
    this.padding,
    this.size = 32,
  });

  final String? symbol;
  final bool fitted;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final double size;

  static bool isSymbolValid(String? code) {
    if (code == null) {
      return false;
    }
    return ManaIcons.icons.containsKey(mapSymbolCode(code));
  }

  static String? mapSymbolCode(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    if (code == "t") {
      code = "tap";
    }
    return code;
  }

  static Color? mapSymbolBackgroundColor(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    switch (code) {
      case "w":
        return const Color.fromARGB(255, 233, 227, 176);
      case "u":
        return const Color.fromARGB(255, 141, 186, 208);
      case "b":
        return const Color.fromARGB(255, 154, 141, 137);
      case "r":
        return const Color.fromARGB(255, 221, 128, 101);
      case "g":
        return const Color.fromARGB(255, 127, 175, 145);
      default:
    }
    if (code == "t" || int.tryParse(code) != null) {
      return const Color.fromARGB(255, 202, 193, 190);
    }
    return null;
  }

  static Color? mapSymbolForegroundColor(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    switch (code) {
      case "w":
        return const Color.fromARGB(255, 32, 28, 20);
      case "u":
        return const Color.fromARGB(255, 5, 24, 33);
      case "b":
        return const Color.fromARGB(255, 18, 11, 13);
      case "r":
        return const Color.fromARGB(255, 31, 0, 0);
      case "g":
        return const Color.fromARGB(255, 0, 21, 10);
      default:
    }
    if (code == "t" || int.tryParse(code) != null) {
      return const Color.fromARGB(255, 18, 11, 13);
    }
    return null;
  }

  bool get valid => isSymbolValid(symbol);

  String? get symbolCode => mapSymbolCode(symbol);

  Color? get backgroundColor => mapSymbolBackgroundColor(symbol);

  Color? get foregroundColor => mapSymbolForegroundColor(symbol);

  @override
  Widget build(BuildContext context) {
    var iconContainer = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.5),
        color: backgroundColor,
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              left: size * 0.1,
              right: size * 0.1,
              top: size * 0.08,
              bottom: size * 0.12,
            ),
        child: Icon(
          ManaIcons.icons[symbolCode] ?? Icons.broken_image,
          color: foregroundColor,
          size: size * 0.8,
        ),
      ),
    );

    return Padding(
      padding: margin,
      child: fitted
          ? FittedBox(
              child: iconContainer,
            )
          : iconContainer,
    );
  }
}
