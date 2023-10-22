import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/widgets/mana_icon.dart';
import 'package:magic_deck_manager/widgets/mana_icons.dart';

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

  @override
  Widget build(BuildContext context) {
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
                child: ManaIcons(
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
            child: Text(
              '${Service.dataLoader.sets.data.firstWhereOrNull((x) => x.code == widget.card.setCode)?.name ?? ''} (${widget.card.setCode})',
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
              return RichText(
                text: TextSpan(
                  children: [
                    for (var span in RegExp(r'({[^}]*})|([^{]*)').allMatches(text))
                      if (span.group(0) != null)
                        RegExp(r'({[^}]*})').hasMatch(span.group(0) ?? '')
                            ? WidgetSpan(
                                child: SizedBox(
                                  height: DefaultTextStyle.of(context).style.fontSize,
                                  child: ManaIcon(color: span.group(0)?.replaceAll(RegExp(r'{|}'), '') ?? ''),
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
        if (widget.selectCard)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(widget.card.uuid);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !(widget.deckCards?.cards.keys.any((e) => e.uuid == widget.card.uuid) ?? false) ? Icons.check : Icons.add,
                      size: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        !(widget.deckCards?.cards.keys.any((e) => e.uuid == widget.card.uuid) ?? false) ? 'Select' : 'Add',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
