/*
 * Magic Deck Manager
 * mana_symbols.dart
 * 
 * Copyright (C) 2023 - 2024 Jefferey Neuffer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
