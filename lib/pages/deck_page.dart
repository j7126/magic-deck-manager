import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/datamodel/deck_card.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/pages/cards_page.dart';
import 'package:magic_deck_manager/widgets/card_preview.dart';
import 'package:magic_deck_manager/widgets/mana_icons.dart';
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
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
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
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SegmentedButton<ManaColor>(
                        segments: <ButtonSegment<ManaColor>>[
                          ButtonSegment<ManaColor>(
                            value: ManaColor.black,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/B.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                          ButtonSegment<ManaColor>(
                            value: ManaColor.green,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/G.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                          ButtonSegment<ManaColor>(
                            value: ManaColor.red,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/R.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                          ButtonSegment<ManaColor>(
                            value: ManaColor.blue,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/U.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                          ButtonSegment<ManaColor>(
                            value: ManaColor.white,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/W.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                          ButtonSegment<ManaColor>(
                            value: ManaColor.none,
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/mana-icons/C.svg',
                                height: 32.0,
                              ),
                            ),
                          ),
                        ],
                        selected: Deck.getColorSet(deck),
                        onSelectionChanged: (Set<ManaColor> newSelection) {
                          var old = Deck.getColorSet(deck);
                          var isColorless = old.contains(ManaColor.none);
                          if (isColorless && newSelection.length > 1) {
                            newSelection.remove(ManaColor.none);
                          }
                          if (!isColorless && newSelection.contains(ManaColor.none)) {
                            newSelection = {ManaColor.none};
                          }
                          setState(() {
                            Deck.setColorSet(deck, newSelection);
                          });
                        },
                        multiSelectionEnabled: true,
                      ),
                    )
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
          IconButton(
            onPressed: exportDeck,
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: editDeck,
            icon: const Icon(Icons.edit),
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
