/*
 * Magic Deck Manager
 * deck_tile.dart
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/ui/symbols/mana_symbols.dart';

class DeckTile extends StatefulWidget {
  const DeckTile({super.key, required this.deck, this.open, this.delete, this.copy});

  final Deck deck;
  final Function? open;
  final Function? delete;
  final Function? copy;

  @override
  State<DeckTile> createState() => _DeckTileState();
}

class _DeckTileState extends State<DeckTile> {
  final FocusNode _menuButtonFocusNode = FocusNode();
  final MenuController _menuController = MenuController();

  bool _tapHandled = false;

  void _handleSecondaryTapDown(TapDownDetails details) {
    _menuController.open(position: details.localPosition);
  }

  void _handleTapDown(TapDownDetails details) {
    if (_menuController.isOpen) {
      _menuController.close();
      _tapHandled = true;
      return;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight)) {
          _menuController.open(position: details.localPosition);
          _tapHandled = true;
          return;
        }
    }
  }

  void _handleTap() {
    if (_tapHandled) {
      _tapHandled = false;
      return;
    }
    widget.open!();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var menuChildren = [
      MenuItemButton(
        child: const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.delete_outline),
            ),
            Text('Delete', style: TextStyle(fontSize: 18)),
          ],
        ),
        onPressed: () => widget.delete!(),
      ),
      MenuItemButton(
        child: const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.copy_outlined),
            ),
            Text('Duplicate', style: TextStyle(fontSize: 18)),
          ],
        ),
        onPressed: () => widget.copy!(),
      ),
    ];

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onSecondaryTapDown: _handleSecondaryTapDown,
      child: MenuAnchor(
        controller: _menuController,
        menuChildren: menuChildren,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: Deck.getBgGradient(widget.deck),
              color: Deck.getBgColor(widget.deck),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      (widget.deck.name.isEmpty)
                          ? Expanded(
                              child: Opacity(
                                opacity: 0.4,
                                child: Text(
                                  'Unnamed deck',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          : Expanded(
                              child: Text(
                                widget.deck.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 28),
                        child: ManaSymbols(mana: ManaColor.getString(Deck.getColorSet(widget.deck))),
                      ),
                      MenuAnchor(
                        childFocusNode: _menuButtonFocusNode,
                        menuChildren: menuChildren,
                        builder: (BuildContext context, MenuController controller, Widget? child) {
                          return IconButton(
                            focusNode: _menuButtonFocusNode,
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            icon: const Icon(Icons.more_vert),
                          );
                        },
                      ),
                    ],
                  ),
                  if (widget.deck.description.isNotEmpty) Text(widget.deck.description)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
