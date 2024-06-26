/*
 * Magic Deck Manager
 * deck_page.dart
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
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/datamodel/deck_card.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/searchable_card.dart';
import 'package:magic_deck_manager/ui/cards/cards_page.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/ui/card/card_preview.dart';
import 'package:magic_deck_manager/ui/symbols/mana_symbols.dart';
import 'package:magic_deck_manager/ui/symbols/mtg_symbol.dart';
import 'package:uuid/uuid.dart';

class DeckPage extends StatefulWidget {
  const DeckPage({super.key, required this.uuid});

  final String? uuid;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> with TickerProviderStateMixin {
  Deck? deck;
  DeckCards? deckCards;
  bool ready = false;
  bool triggerEditModal = false;

  DeckListType selectedDeckListType = DeckListType.namesAtomic;
  bool deckListIncludeLands = true;

  String filter = '';

  SearchableCard? commander;
  SearchableCard? commanderPartner;

  late ScrollController _scrollController;
  late TextEditingController _searchFieldController;
  late final TabController _tabController;

  void setup() async {
    if (widget.uuid != null) {
      deck = await Deck.fromUUID(widget.uuid ?? '');
    } else {
      deck = Deck(uuid: const Uuid().v4(), name: '', description: '', cards: [], colors: '');
    }
    if (deck != null && Deck.getColorSet(deck).isEmpty) {
      Deck.setColorSet(deck, {ManaColor.none});
    }
    deckCards = await DeckCards.fromDeck(deck);
    getCommanders();
    ready = true;
    if (widget.uuid == null) {
      triggerEditModal = true;
    }

    setState(() {});
  }

  void getCommanders() {
    commander = null;
    commanderPartner = null;
    var commanders = deckCards?.cards.entries.where((e) => e.key.commander).toList();
    if (commanders != null && commanders.isNotEmpty) {
      commander = Service.dataLoader.searchableCards.data.firstWhereOrNull((e) => e.name == commanders[0].value.name);
      if (commanders.length >= 2 && commander != null && (commander?.keywords?.contains("Partner") ?? false)) {
        commanderPartner = Service.dataLoader.searchableCards.data.firstWhereOrNull((e) => e.name == commanders[1].value.name);
      }
    }
  }

  Future save() async {
    await Deck.save(deck);
  }

  Future refreshCards() async {
    await Deck.refreshCards(deck);
    deckCards = await DeckCards.fromDeck(deck);
  }

  void addCard() async {
    if (deck == null) return;
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardsPage(
          isModal: true,
          deckCards: deckCards,
        ),
      ),
    );
    if (result is String) {
      if (result != "") {
        await deckCards?.addUUID(result);
      }
    }
    getCommanders();
    setState(() {});
    save();
  }

  Future editColors() async {
    if (deck == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return AlertDialog(
              title: const Text(
                'Colors',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var color in [ManaColor.black, ManaColor.green, ManaColor.red, ManaColor.blue, ManaColor.white])
                      CheckboxListTile(
                        title: Row(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 22),
                              child: MtgSymbol(symbol: color.str),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(color.name),
                            )
                          ],
                        ),
                        value: Deck.getColorSet(deck).contains(color),
                        onChanged: (bool? value) {
                          if (value == null) {
                            return;
                          }
                          var colors = Deck.getColorSet(deck);
                          if (value) {
                            colors.add(color);
                            colors.remove(ManaColor.none);
                          } else {
                            colors.remove(color);
                            if (colors.isEmpty) {
                              colors = {ManaColor.none};
                            }
                          }
                          setState(() {
                            Deck.setColorSet(deck, colors);
                          });
                        },
                      ),
                    CheckboxListTile(
                      title: Row(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 22),
                            child: MtgSymbol(symbol: ManaColor.none.str),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(ManaColor.none.name),
                          )
                        ],
                      ),
                      value: Deck.getColorSet(deck).contains(ManaColor.none),
                      onChanged: (bool? value) {
                        if (value == null) {
                          return;
                        }
                        var colors = Deck.getColorSet(deck);
                        if (value) {
                          colors = {ManaColor.none};
                        }
                        setState(() {
                          Deck.setColorSet(deck, colors);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future setCardCommander(SearchableCard? c, bool state) async {
    if (c != null && deckCards != null) {
      if (!(deckCards?.cards.entries.any((x) => x.value.name == c.name) ?? false)) {
        var cards = await Service.dataLoader.cardsByName(c.name);
        if (cards.isNotEmpty) {
          await deckCards?.addUUID(cards.first.uuid);
        }
      }
      var cardSet = deckCards?.cards.entries.firstWhere((x) => x.value.name == c.name);
      deck?.cards.firstWhere((x) => x.uuid == cardSet?.key.uuid).commander = state;

      if (state && commanderPartner != null && !(c.keywords?.contains("Partner") ?? false)) {
        if (c.name == commander?.name) {
          setCardCommander(commanderPartner, false);
          commanderPartner = null;
        } else if (c.name == commanderPartner?.name) {
          setCardCommander(commander, false);
          commander = commanderPartner;
          commanderPartner = null;
        }
      }
    }
  }

  void setDeckColorsByCommanders() {
    var colors = <ManaColor>{};
    if (commander != null) {
      colors.addAll(commander!.colorIdentity.map((e) => ManaColor.fromStr(e)));
    }
    if (commanderPartner != null) {
      colors.addAll(commanderPartner!.colorIdentity.map((e) => ManaColor.fromStr(e)));
    }
    Deck.setColorSet(deck, colors);
  }

  void editDeck() async {
    if (deck == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.only(top: 12.0, left: 20.0, right: 20.0, bottom: 0.0),
              contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0, top: 8.0),
              title: const Text(
                'Edit deck',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FilledButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 350.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Gap(8.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Name'),
                          isDense: true,
                        ),
                        initialValue: deck?.name,
                        onChanged: (value) {
                          setState(() {
                            deck?.name = value;
                          });
                        },
                      ),
                      const Gap(16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Description'),
                          isDense: true,
                        ),
                        initialValue: deck?.description,
                        onChanged: (value) {
                          setState(() {
                            deck?.description = value;
                          });
                        },
                      ),
                      const Gap(16.0),
                      DropdownMenu<String?>(
                        inputDecorationTheme: const InputDecorationTheme(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        enableFilter: false,
                        requestFocusOnTap: false,
                        expandedInsets: EdgeInsets.zero,
                        label: const Text("Format"),
                        initialSelection: deck?.format,
                        onSelected: (String? val) {
                          setState(() {
                            deck?.format = val;
                            if (val != "Commander") {
                              commander = null;
                              commanderPartner = null;
                            }
                          });
                        },
                        dropdownMenuEntries: [
                          null,
                          "Commander",
                          "Standard",
                          "Modern",
                        ]
                            .map(
                              (e) => DropdownMenuEntry<String?>(
                                value: e,
                                label: e ?? "Unknown",
                              ),
                            )
                            .toList(),
                      ),
                      if (deck?.format == "Commander") const Gap(16.0),
                      if (deck?.format == "Commander")
                        LayoutBuilder(builder: (context, constraints) {
                          return Autocomplete<SearchableCard>(
                            initialValue: TextEditingValue(text: commander?.name ?? ''),
                            displayStringForOption: (option) => option.name,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const [];
                              }
                              return Service.dataLoader.searchableCards
                                  .searchCards(textEditingValue.text)
                                  .where(
                                    (e) => e.leadershipSkills?.commander ?? false,
                                  )
                                  .take(5);
                            },
                            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onSubmitted: (_) => onFieldSubmitted(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Commander',
                                isDense: true,
                              ),
                            ),
                            optionsViewBuilder: (context, onSelected, options) => Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 48.0 * options.length,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: ListView(
                                    children: <Widget>[
                                      for (var option in options)
                                        ListTile(
                                          title: Text(option.name),
                                          onTap: () => onSelected(option),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onSelected: (SearchableCard selection) async {
                              var oldCommander = commander;
                              commander = selection;
                              if (oldCommander != null && oldCommander != commander) {
                                await setCardCommander(oldCommander, false);
                              }
                              await setCardCommander(commander, true);
                              setDeckColorsByCommanders();
                              setState(() {});
                              await save();
                            },
                          );
                        }),
                      if (deck?.format == "Commander" && (commander?.keywords?.contains("Partner") ?? false)) const Gap(16.0),
                      if (deck?.format == "Commander" && (commander?.keywords?.contains("Partner") ?? false))
                        LayoutBuilder(builder: (context, constraints) {
                          return Autocomplete<SearchableCard>(
                            initialValue: TextEditingValue(text: commanderPartner?.name ?? ''),
                            displayStringForOption: (option) => option.name,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const [];
                              }
                              return Service.dataLoader.searchableCards
                                  .searchCards(textEditingValue.text)
                                  .where((e) =>
                                      e.name != commander?.name &&
                                      (e.leadershipSkills?.commander ?? false) &&
                                      (e.keywords?.contains("Partner") ?? false))
                                  .take(5);
                            },
                            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onSubmitted: (_) => onFieldSubmitted(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Partner Commander',
                                isDense: true,
                              ),
                            ),
                            optionsViewBuilder: (context, onSelected, options) => Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 48.0 * options.length,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: ListView(
                                    children: <Widget>[
                                      for (var option in options)
                                        ListTile(
                                          title: Text(option.name),
                                          onTap: () => onSelected(option),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onSelected: (SearchableCard selection) async {
                              var oldCommander = commanderPartner;
                              commanderPartner = selection;
                              if (oldCommander != null && oldCommander != commanderPartner) {
                                await setCardCommander(oldCommander, false);
                              }
                              await setCardCommander(commanderPartner, true);
                              setDeckColorsByCommanders();
                              setState(() {});
                              await save();
                            },
                          );
                        }),
                      const Gap(16.0),
                      GestureDetector(
                        onTap: () async {
                          await editColors();
                          setState(() {});
                        },
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 32),
                                  child: ManaSymbols(mana: ManaColor.getString(Deck.getColorSet(deck))),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () async {
                                    await editColors();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    save();
    setState(() {});
  }

  void exportDeck() async {
    if (deck == null) {
      return;
    }
    var resultFieldController = TextEditingController(text: DeckCards.getDeckList(deckCards, selectedDeckListType, deckListIncludeLands));
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return AlertDialog(
              title: const Text(
                'Export deck list',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FilledButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) => DropdownMenu<DeckListType>(
                            inputDecorationTheme: const InputDecorationTheme(
                              border: OutlineInputBorder(),
                            ),
                            width: constraints.maxWidth,
                            enableSearch: false,
                            requestFocusOnTap: false,
                            initialSelection: selectedDeckListType,
                            label: const Text('List format'),
                            dropdownMenuEntries: DeckListType.values
                                .map(
                                  (e) => DropdownMenuEntry<DeckListType>(value: e, label: e.label),
                                )
                                .toList(),
                            onSelected: (DeckListType? listType) {
                              if (listType != null) {
                                selectedDeckListType = listType;
                                resultFieldController.text = DeckCards.getDeckList(deckCards, selectedDeckListType, deckListIncludeLands);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SwitchListTile(
                            title: const Text('Include Basic Land'),
                            value: deckListIncludeLands,
                            onChanged: (bool value) {
                              setState(() {
                                deckListIncludeLands = value;
                                resultFieldController.text = DeckCards.getDeckList(deckCards, selectedDeckListType, deckListIncludeLands);
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            readOnly: true,
                            maxLines: 8,
                            controller: resultFieldController,
                            onTap: () => resultFieldController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: resultFieldController.value.text.length,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Deck List'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          },
        );
      },
    );
    save();
    setState(() {});
  }

  void importDeck() async {
    if (deck == null) {
      return;
    }
    var resultFieldController = TextEditingController();
    var loading = false;
    List<bool>? result;
    String value = "";
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return AlertDialog(
              title: const Text(
                'Import deck list',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                if (loading && result != null && (result?.any((element) => !element) ?? false))
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                if (!loading)
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                if (!loading)
                  FilledButton(
                    child: const Text('Import'),
                    onPressed: () {
                      () async {
                        loading = true;
                        setState(() {});
                        value = resultFieldController.text;
                        result = await DeckCards.importDeckList(deckCards, selectedDeckListType, resultFieldController.text);
                      }()
                          .then((_) {
                        if (!(result?.any((element) => !element) ?? false)) {
                          Navigator.of(context).pop();
                        }
                        setState(() {});
                      });
                    },
                  ),
              ],
              content: loading
                  ? result != null && (result?.any((element) => !element) ?? false)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "The following lines could not be imported.\nCheck the list format?",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: double.infinity,
                                      height: 0,
                                    ),
                                    for (var (index, line) in value.split('\n').indexed)
                                      if (!(result?[index] ?? true)) Text(line),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                          ],
                        )
                  : Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) => DropdownMenu<DeckListType>(
                                inputDecorationTheme: const InputDecorationTheme(
                                  border: OutlineInputBorder(),
                                ),
                                width: constraints.maxWidth,
                                enableSearch: false,
                                requestFocusOnTap: false,
                                initialSelection: selectedDeckListType,
                                label: const Text('List format'),
                                dropdownMenuEntries: DeckListType.values
                                    .map(
                                      (e) => DropdownMenuEntry<DeckListType>(value: e, label: e.label),
                                    )
                                    .toList(),
                                onSelected: (DeckListType? listType) {
                                  if (listType != null) {
                                    selectedDeckListType = listType;
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: TextFormField(
                                maxLines: 8,
                                controller: resultFieldController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Deck List'),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
            );
          },
        );
      },
    );
    save();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  void initState() {
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    setup();
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bgGradient = Deck.getBgGradient(deck);
    var bgColor = Deck.getBgColor(deck);

    if (triggerEditModal) {
      triggerEditModal = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => editDeck());
    }

    return Scaffold(
      appBar: ready
          ? AppBar(
              scrolledUnderElevation: 4,
              shadowColor: Theme.of(context).colorScheme.shadow,
              titleSpacing: 4.0,
              title: !ready
                  ? Container()
                  : Row(
                      children: [
                        Expanded(
                          child: deck?.name.isEmpty ?? true
                              ? const Opacity(
                                  opacity: 0.4,
                                  child: Text(
                                    'Unnamed deck',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : Text(
                                  deck?.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (commander == null)
                          Row(
                            children: [
                              const Icon(
                                CustomIcons.cards_outlined,
                                size: 20.0,
                              ),
                              const Gap(4.0),
                              Text(
                                deckCards?.cards.entries.map((e) => e.key.qty).sum.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: bgGradient,
                    color: bgColor,
                  ),
                ),
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: editDeck,
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.edit),
                          ),
                          Text('Edit Deck'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: exportDeck,
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.publish_rounded),
                          ),
                          Text('Export Deck List'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: importDeck,
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.download_rounded),
                          ),
                          Text('Import Deck List'),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(44 + (commander != null ? 40.0 : 0.0)),
                child: Column(
                  children: [
                    if (commander != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                        child: Row(
                          children: [
                            if (deck?.format == "Commander" && commander?.name != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(KeyruneIcons.ss_cmd),
                                    const Gap(6.0),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            commander?.name ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: commanderPartner != null ? 14.0 : 16.0,
                                              height: 0.9,
                                            ),
                                          ),
                                          if (commanderPartner != null)
                                            Text(
                                              commanderPartner?.name ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(fontSize: 14.0),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 22),
                              child: ManaSymbols(mana: ManaColor.getString(Deck.getColorSet(deck))),
                            ),
                            const Gap(16.0),
                            const Icon(CustomIcons.cards_outlined),
                            const Gap(4.0),
                            Text(
                              deckCards?.cards.entries.map((e) => e.key.qty).sum.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const Gap(12.0),
                          ],
                        ),
                      ),
                    const Gap(2.0),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CustomIcons.cards_filled),
                              Gap(8.0),
                              Text('Cards'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pie_chart),
                              Gap(8.0),
                              Text('Insights'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : const PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: LinearProgressIndicator(),
            ),
      floatingActionButton: ready
          ? FloatingActionButton.extended(
              onPressed: () {
                addCard();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add card"),
            )
          : null,
      body: Stack(
        children: [
          if (!ready)
            Center(
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
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (ready)
            Container(
              decoration: BoxDecoration(
                gradient: bgGradient,
                color: bgColor,
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextField(
                        controller: _searchFieldController,
                        decoration: InputDecoration(
                          hintText: "Filter Cards",
                          border: const UnderlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchFieldController.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchFieldController.clear();
                                    filter = '';
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                              PopupMenuButton<String>(
                                initialValue: filter,
                                icon: Icon(
                                  filter.isNotEmpty ? Icons.filter_alt : Icons.filter_alt_outlined,
                                  color: filter.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                ),
                                onSelected: (String value) {
                                  setState(() {
                                    filter = value;
                                  });
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: '',
                                    child: Text('Any'),
                                  ),
                                  for (var type in DeckCards.getTypes(deckCards).entries)
                                    PopupMenuItem<String>(
                                      value: type.key,
                                      child: Text('${type.key} (${type.value})'),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                        }),
                      ),
                      Expanded(
                        child: GridView.extent(
                          maxCrossAxisExtent: 300,
                          childAspectRatio: 488 / 680,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 12.0),
                          children: [
                            for (MapEntry<DeckCard, CardSet> card in deckCards?.cards.entries.sorted((a, b) {
                                  if (a.key.commander != b.key.commander) {
                                    return (b.key.commander ? 1 : 0) - (a.key.commander ? 1 : 0);
                                  }
                                  return a.value.name.toLowerCase().compareTo(b.value.name.toLowerCase());
                                }) ??
                                [])
                              if ((_searchFieldController.text.isEmpty ||
                                      Service.dataLoader.searchableCards.data
                                          .firstWhere((e) => e.name == card.value.name)
                                          .cardSearchString
                                          .contains(SearchableCard.filterStringForSearch(_searchFieldController.text))) &&
                                  (filter.isEmpty || card.value.types.contains(filter)))
                                CardPreview(
                                  key: Key(card.key.uuid),
                                  card: card.value,
                                  qty: card.key.qty,
                                  dialogPreview: true,
                                  isCommander: card.key.commander,
                                  qtyChanged: (var val) async {
                                    if (deckCards != null) {
                                      await deckCards?.setQty(card.key.uuid, val);
                                      getCommanders();
                                      setState(() {});
                                      save();
                                    }
                                  },
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    var minDimension = min(constraints.maxWidth, constraints.maxHeight);
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Builder(builder: (context) {
                            var chartSections = <PieChartSectionData>[];
                            var total = 0.0;
                            for (var color in [
                              ManaColor.black,
                              ManaColor.green,
                              ManaColor.red,
                              ManaColor.blue,
                              ManaColor.white,
                              ManaColor.none,
                            ]) {
                              var colorstr = color == ManaColor.none ? "C" : ManaColor.getString(color);
                              var val = deckCards?.cards.entries
                                  .where(
                                    (x) =>
                                        !x.value.types.contains("Land") && x.value.colorIdentity.contains(colorstr == "C" ? "" : colorstr),
                                  )
                                  .map((e) => e.key.qty)
                                  .sum
                                  .toDouble();
                              if (val != null && val > 0) {
                                total += val;
                                chartSections.add(PieChartSectionData(
                                  color: MtgSymbol.mapSymbolBackgroundColor(colorstr),
                                  badgeWidget: MtgSymbol(symbol: colorstr),
                                  titleStyle: TextStyle(
                                    color: MtgSymbol.mapSymbolForegroundColor(colorstr),
                                  ),
                                  value: val,
                                ));
                              }
                            }
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Card Colors",
                                          style: TextStyle(fontSize: 24.0),
                                        ),
                                        for (var section in chartSections)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: [
                                                const Gap(4.0),
                                                SizedBox(
                                                  width: 24.0,
                                                  height: 24.0,
                                                  child: section.badgeWidget ?? Container(),
                                                ),
                                                const Gap(8.0),
                                                Text(
                                                  "${(section.value / total * 100).toStringAsFixed(1)}%",
                                                  style: const TextStyle(fontSize: 20.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: minDimension / 3,
                                      height: minDimension / 3,
                                      child: PieChart(
                                        PieChartData(
                                          sections: chartSections,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
