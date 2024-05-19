import 'package:flutter/material.dart';
import 'package:magic_deck_manager/ui/symbols/mtg_symbol.dart';

class ManaSymbols extends StatelessWidget {
  const ManaSymbols({
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
            MtgSymbol(
              symbol: c,
              margin: EdgeInsets.symmetric(horizontal: padding),
            ),
      ],
    );
  }
}
