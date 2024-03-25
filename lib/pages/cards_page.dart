import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/searchable_card.dart';
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

  List<SearchableCard> cards = [];

  List<SearchableCard> cardsFiltered = [];

  String filter = '';

  void searchCards(String searchStr) async {
    var cards = Service.dataLoader.searchableCards.searchCards(searchStr);
    if (searchStr == _searchFieldController.text) {
      setState(() {
        this.cards = cards;
        filterCards();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  void filterCards() {
    cardsFiltered = cards.where((element) => filter.isEmpty || element.types.any((x) => x.toLowerCase() == filter.toLowerCase())).toList();
  }

  @override
  void initState() {
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.isModal ? null : const NavMenu(),
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text('Search cards'),
        titleSpacing: 4.0,
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
                          setState(() {
                            _searchFieldController.clear();
                            filter = '';
                            cards.clear();
                            cardsFiltered.clear();
                          });
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
                          filterCards();
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: '',
                          child: Text('Any'),
                        ),
                        for (var type in SearchableCard.filterTypes)
                          PopupMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                      ],
                    )
                  ],
                )),
            autofocus: true,
            onChanged: (value) => searchCards(value),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            if (_searchFieldController.text.isEmpty || cardsFiltered.isEmpty)
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
                            cardsFiltered.isEmpty ? "No results found" : "",
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
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 488 / 680,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  controller: _scrollController,
                  itemCount: cardsFiltered.length,
                  itemBuilder: (BuildContext context, int index) {
                    var card = cardsFiltered[index];
                    return CardPreview(
                      key: Key(card.name),
                      card: card,
                      selectCard: widget.isModal,
                      deckCards: widget.deckCards,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
