import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.open!(),
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
                      child: ManaIcons(mana: ManaColor.getString(Deck.getColorSet(widget.deck))),
                    ),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.delete_outline),
                              ),
                              Text('Delete', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          onTap: () => widget.delete!(),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.copy_outlined),
                              ),
                              Text('Duplicate', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          onTap: () => widget.copy!(),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.deck.description.isNotEmpty) Text(widget.deck.description)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
