/*
 * Magic Deck Manager
 * decks_page.dart
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:magic_deck_manager/ui/deck/deck_page.dart';
import 'package:magic_deck_manager/ui/decks/deck_tile.dart';
import 'package:magic_deck_manager/ui/nav.dart';
import 'package:uuid/uuid.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  late ScrollController _scrollController;

  List<Deck> decks = [];
  bool ready = false;

  void setup() async {
    decks = await Deck.getDecks();
    setState(() {
      ready = true;
    });
  }

  void refreshDecks() async {
    setState(() {
      ready = false;
    });
    decks = await Deck.getDecks();
    setState(() {
      ready = true;
    });
  }

  void openDeck(String? uuid) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => DeckPage(uuid: uuid),
          ),
        )
        .then((value) => refreshDecks());
  }

  void deleteDeck(String? uuid) async {
    await Deck.deleteUUID(uuid);
    refreshDecks();
  }

  void copyDeck(String? uuid) async {
    var deckJson = decks.firstWhere((x) => x.uuid == uuid).toJson();
    deckJson['uuid'] = const Uuid().v4();
    deckJson['name'] += " (copy)";
    var deck = Deck.fromJson(deckJson);
    await Deck.save(deck);
    refreshDecks();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavMenu(),
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text("Decks"),
        titleSpacing: 4.0,
      ),
      floatingActionButton: ready
          ? FloatingActionButton.extended(
              onPressed: () {
                openDeck(null);
              },
              icon: const Icon(Icons.add),
              label: const Text("New Deck"),
            )
          : null,
      body: Column(
        children: [
          if (!ready) const LinearProgressIndicator(),
          if (decks.isEmpty)
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints bc) {
                    var size = min(bc.maxHeight, bc.maxWidth) * 0.5;
                    return Opacity(
                      opacity: 0.3,
                      child: Column(
                        children: [
                          const Spacer(),
                          Icon(
                            CustomIcons.deck_outlined,
                            size: size,
                          ),
                          if (ready)
                            Text(
                              "You don't have any decks yet!",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size * 0.13,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                controller: _scrollController,
                children: [
                  for (var deck in decks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DeckTile(
                        key: Key(deck.uuid),
                        deck: deck,
                        open: () => openDeck(deck.uuid),
                        delete: () => deleteDeck(deck.uuid),
                        copy: () => copyDeck(deck.uuid),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
