import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/datamodel/deck_card.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/pages/cards_page.dart';
import 'package:magic_deck_manager/widgets/card_preview.dart';
import 'package:magic_deck_manager/widgets/mana_icons.dart';
import 'package:magic_deck_manager/widgets/mtg_symbol.dart';
import 'package:uuid/uuid.dart';

class DeckPage extends StatefulWidget {
  const DeckPage({super.key, required this.uuid});

  final String? uuid;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  Deck? deck;
  DeckCards? deckCards;
  bool ready = false;
  bool triggerEditModal = false;

  DeckListType selectedDeckListType = DeckListType.namesAtomic;
  bool deckListIncludeLands = true;

  String filter = '';

  late ScrollController _scrollController;
  late TextEditingController _searchFieldController;

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
    ready = true;
    if (widget.uuid == null) {
      triggerEditModal = true;
    }

    setState(() {});
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
      await deckCards?.addUUID(result);
      setState(() {});
      save();
    }
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
                              child: MtgSymbol(color: color.str),
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
                            child: MtgSymbol(color: ManaColor.none.str),
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
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Name'),
                        ),
                        initialValue: deck?.name,
                        onChanged: (value) {
                          setState(() {
                            deck?.name = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Description'),
                        ),
                        initialValue: deck?.description,
                        onChanged: (value) {
                          setState(() {
                            deck?.description = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: GestureDetector(
                        onTap: () async {
                          await editColors();
                          setState(() {});
                        },
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 32),
                                  child: ManaIcons(mana: ManaColor.getString(Deck.getColorSet(deck))),
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
                    ),
                    const SizedBox(
                      width: 350,
                      height: 0,
                    ),
                  ],
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
                            for (var (index, line) in value.split('\n').indexed)
                              if (!(result?[index] ?? true)) Text(line),
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
    setup();
    super.initState();
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
            color: bgColor,
          ),
        ),
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: !ready
            ? Container()
            : deck?.name.isEmpty ?? true
                ? const Opacity(
                    opacity: 0.4,
                    child: Text('Unnamed deck'),
                  )
                : Text(deck?.name ?? ''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                const Icon(CustomIcons.cards_outlined),
                Text(
                  deckCards?.cards.entries.map((e) => e.key.qty).sum.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 22),
            child: ManaIcons(mana: ManaColor.getString(Deck.getColorSet(deck))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(),
          ),
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
          preferredSize: const Size.fromHeight(40),
          child: TextField(
            controller: _searchFieldController,
            decoration: InputDecoration(
              hintText: "Search",
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
        ),
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
      body: ready
          ? Container(
              decoration: BoxDecoration(
                gradient: bgGradient,
                color: bgColor,
              ),
              child: GridView.extent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 488 / 680,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.all(16),
                controller: _scrollController,
                children: [
                  for (MapEntry<DeckCard, CardSet> card in deckCards?.cards.entries ?? [])
                    if ((_searchFieldController.text.isEmpty ||
                            card.value.name.toLowerCase().contains(_searchFieldController.text.toLowerCase())) &&
                        (filter.isEmpty || card.value.types.contains(filter)))
                      CardPreview(
                        key: Key(card.key.uuid),
                        card: card.value,
                        qty: card.key.qty,
                        dialogPreview: true,
                        qtyChanged: (var val) async {
                          if (deckCards != null) {
                            await deckCards?.setQty(card.key.uuid, val);
                            setState(() {});
                            save();
                          }
                        },
                      ),
                ],
              ),
            )
          : Column(
              children: [
                const LinearProgressIndicator(),
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
                              const Spacer(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
