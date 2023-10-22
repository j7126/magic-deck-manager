import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_atomic.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:magic_deck_manager/widgets/card_preview.dart';
import 'package:magic_deck_manager/widgets/nav.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key, this.isModal = false, this.deckCards});

  final bool isModal;
  final DeckCards? deckCards;

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late TextEditingController _searchFieldController;
  late ScrollController _scrollController;

  static const int cardsShownIncrement = 25;
  int numCardsShown = cardsShownIncrement;

  String filter = '';

  @override
  void initState() {
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cards = Service.dataLoader.atomicCards.data.keys.where(
      (element) {
        if (element.toLowerCase().contains(_searchFieldController.text.toLowerCase())) {
          var cardList = Service.dataLoader.atomicCards.data[element];
          if (cardList != null && cardList.isNotEmpty) {
            if (filter.isEmpty || cardList.first.types.any((type) => type.toLowerCase() == filter.toLowerCase())) {
              return true;
            }
          }
        }
        return false;
      },
    );
    var cardsShown = cards.take(numCardsShown);

    return Scaffold(
      drawer: widget.isModal ? null : const NavMenu(),
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text('Search cards'),
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
                        for (var type in CardAtomic.filterTypes)
                          PopupMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                      ],
                    )
                  ],
                )),
            autofocus: true,
            onChanged: (value) => setState(() {
              numCardsShown = cardsShownIncrement;
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0);
              }
            }),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            if (_searchFieldController.text.isEmpty || cardsShown.isEmpty)
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints bc) {
                    var size = min(bc.maxHeight, bc.maxWidth) * 0.5;
                    return Opacity(
                      opacity: 0.3,
                      child: Column(
                        children: [
                          const Spacer(),
                          Icon(
                            CustomIcons.cards_outlined,
                            size: size,
                          ),
                          Text(
                            cardsShown.isEmpty ? "No results found" : "",
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
              )
            else
              Expanded(
                child: GridView.extent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 488 / 680,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  padding: const EdgeInsets.all(16),
                  controller: _scrollController,
                  children: [
                    for (var card in cardsShown)
                      CardPreview(
                        key: Key(card),
                        card: Service.dataLoader.atomicCards.data[card]?.first,
                        selectCard: widget.isModal,
                        deckCards: widget.deckCards,
                      ),
                    if (cards.length > numCardsShown)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              setState(() {
                                numCardsShown += cardsShownIncrement;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.expand_circle_down_outlined,
                                    size: 28,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      "Show More",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
