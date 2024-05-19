/*
 * Magic Deck Manager
 * card_page.dart
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
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/ui/card/card_preview.dart';
import 'package:magic_deck_manager/ui/card/card_text_preview.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.card, this.selectCard = false, this.deckCards});

  final String card;
  final bool selectCard;
  final DeckCards? deckCards;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  bool ready = false;
  bool valid = true;
  String imageUrl = '';

  List<CardSet> cardSets = [];

  void setup() async {
    cardSets = await Service.dataLoader.cardsByName(widget.card);
    String? id = cardSets.first.identifiers.scryfallId;
    if (id == null) {
      valid = false;
      return;
    }
    String fileFace = 'front';
    String fileType = 'normal';
    String dir1 = id[0];
    String dir2 = id[1];
    imageUrl = 'https://cards.scryfall.io/$fileType/$fileFace/$dir1/$dir2/$id.jpg';
    ready = true;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  Widget buildCardSetItem(BuildContext context, CardSet c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              var isLg = constraints.maxWidth > 500;
              var preview = Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: CardPreview(
                    card: c,
                    hideButtons: true,
                    dialogPreview: true,
                  ),
                ),
              );
              return Flex(
                direction: isLg ? Axis.horizontal : Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLg && Service.settingsService.pref_getScryfallImages) preview,
                  Expanded(
                    flex: isLg ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: CardTextPreview(
                          card: c,
                          deckCards: widget.deckCards,
                          selectCard: widget.selectCard,
                        ),
                      ),
                    ),
                  ),
                  if (!isLg && Service.settingsService.pref_getScryfallImages) preview,
                ],
              );
            },
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    LinearGradient? bgGradient;
    Color? bgColor;
    if (cardSets.isNotEmpty) {
      var colors = cardSets[0].colorIdentity.map((s) => ManaColor.fromStr(s));
      if (colors.isNotEmpty) {
        var bgOpacity = 40;
        bgGradient = colors.length >= 2
            ? LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: colors.map((c) => ManaColor.getColor(c, opacity: bgOpacity)).toList(),
              )
            : null;
        bgColor = colors.length < 2 ? ManaColor.getColor(colors.first, opacity: bgOpacity) : null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
            color: bgColor,
          ),
        ),
        titleSpacing: 4.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
          color: bgColor,
        ),
        width: double.infinity,
        height: double.infinity,
        child: ready && valid
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var c in cardSets.where((x) => widget.deckCards?.cards.entries.any((e) => e.value.uuid == x.uuid) ?? false))
                      buildCardSetItem(context, c),
                    for (var c in cardSets.where((x) => !(widget.deckCards?.cards.entries.any((e) => e.value.uuid == x.uuid) ?? false)))
                      buildCardSetItem(context, c),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
