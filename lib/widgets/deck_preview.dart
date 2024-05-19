import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/widgets/mana_icons.dart';

class DeckPreview extends StatefulWidget {
  const DeckPreview({super.key, required this.deck, this.open, this.delete, this.copy});

  final Deck deck;
  final Function? open;
  final Function? delete;
  final Function? copy;

  @override
  State<DeckPreview> createState() => _DeckPreviewState();
}

class _DeckPreviewState extends State<DeckPreview> {
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
                        child: ManaIconsWidget(mana: ManaColor.getString(Deck.getColorSet(widget.deck))),
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
