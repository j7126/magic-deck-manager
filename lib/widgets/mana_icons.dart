import 'package:flutter/material.dart';
import 'package:magic_deck_manager/widgets/mtg_symbol.dart';

class ManaIconsWidget extends StatelessWidget {
  const ManaIconsWidget({
    super.key,
    required this.mana,
    this.padding = 4,
    this.expand = true,
  });

  final String mana;
  final double padding;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var c in mana.replaceAll('{', '').split('}'))
          if (c.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: MtgSymbol(color: c),
            ),
      ],
    );
  }
}
