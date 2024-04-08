import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/widgets/mana_icons.dart';
import 'package:magic_deck_manager/widgets/quantity_buttons.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';

class CardTextPreview extends StatefulWidget {
  const CardTextPreview({
    super.key,
    required this.card,
    this.selectCard = false,
    this.showSet = true,
    this.deckCards,
  });

  final CardSet card;
  final bool selectCard;
  final bool showSet;
  final DeckCards? deckCards;

  @override
  State<CardTextPreview> createState() => _CardTextPreviewState();
}

class _CardTextPreviewState extends State<CardTextPreview> {
  @override
  void initState() {
    super.initState();
  }

  String? mapSymbolCode(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    if (code == "t") {
      code = "tap";
    }
    return code;
  }

  Color? mapSymbolBackgroundColor(String? code) {
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

  Color? mapSymbolForegroundColor(String? code) {
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

  @override
  Widget build(BuildContext context) {
    var mtgSet = Service.dataLoader.sets.data.firstWhereOrNull((x) => x.code == widget.card.setCode);
    var cardInDeck = (widget.deckCards?.cards.keys.any((e) => e.uuid == widget.card.uuid) ?? false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runSpacing: 8.0,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 28),
                child: ManaIconsWidget(
                  mana: widget.card.manaCost ?? '',
                  expand: false,
                ),
              ),
            ),
            if (widget.card.power != null && widget.card.toughness != null)
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  child: Text('${widget.card.power ?? '*'} / ${widget.card.toughness ?? '*'}'),
                ),
              ),
          ],
        ),
        if (widget.showSet)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mtgSet != null && KeyruneIcons.icons.containsKey(mtgSet.keyruneCode.toLowerCase()))
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      size: 18,
                      KeyruneIcons.icons[mtgSet.keyruneCode.toLowerCase()],
                    ),
                  ),
                Text(
                  '${Service.dataLoader.sets.data.firstWhereOrNull((x) => x.code == widget.card.setCode)?.name ?? ''} (${widget.card.setCode})',
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            widget.card.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text((widget.card.type)),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Builder(
            builder: (context) {
              var text = (widget.card.text ?? widget.card.text ?? '').replaceAll('\\n', '\n');
              var spans = RegExp(r'({)([^}]*)(})|([^{]*)').allMatches(text).where((element) => element.group(0) != null);
              return RichText(
                text: TextSpan(
                  children: [
                    for (var span in spans)
                      span.groupCount > 1 && ManaIcons.icons.containsKey(mapSymbolCode(span.group(2)))
                          ? WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 1) * 0.1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular((Theme.of(context).textTheme.bodyLarge?.fontSize ?? 1) * 0.5),
                                    color: mapSymbolBackgroundColor(span.group(2)),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Padding(
                                    padding: EdgeInsets.all((Theme.of(context).textTheme.bodyLarge?.fontSize ?? 1) * 0.1),
                                    child: Icon(
                                      ManaIcons.icons[mapSymbolCode(span.group(2))],
                                      color: mapSymbolForegroundColor(span.group(2)),
                                      size: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 1) * 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : TextSpan(
                              text: span.group(0),
                            ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.selectCard && cardInDeck)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                QuantityButtons(
                  qty: widget.deckCards?.cards.keys.firstWhere((x) => x.uuid == widget.card.uuid).qty ?? 1,
                  qtyChanged: (qty) {
                    if (widget.deckCards != null) {
                      setState(() {
                        widget.deckCards?.setQty(widget.card.uuid, qty);
                      });
                    }
                  },
                ),
                const Gap(8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop("");
                  },
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      Colors.green,
                    ),
                    foregroundColor: MaterialStatePropertyAll(
                      Colors.white,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (widget.selectCard && !cardInDeck)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(widget.card.uuid);
              },
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 24,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
