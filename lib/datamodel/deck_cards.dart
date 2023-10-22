import 'package:magic_deck_manager/datamodel/deck.dart';
import 'package:magic_deck_manager/datamodel/deck_card.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/service/static_service.dart';

enum DeckListType {
  namesAtomic('Quantity Name'),
  namesSet('Quantity Name (Set)'),
  namesAtomicNoQty('Name'),
  namesSetNoQty('Name (Set)'),
  scryfallId('Scryfall ID (Quantity)');

  const DeckListType(this.label);

  final String label;
}

class DeckCards {
  static Future<DeckCards?> fromDeck(Deck? deck) async {
    if (deck == null) return null;
    var result = DeckCards();
    result.deck = deck;
    for (var card in deck.cards) {
      var cs = await CardSet.fromUUID(card.uuid, Service.dataLoader.db);
      if (cs != null) result.cards[card] = cs;
    }
    return result;
  }

  final Map<DeckCard, CardSet> cards = {};
  late Deck deck;

  Future addUUID(String uuid) async {
    if (deck.cards.any((element) => element.uuid == uuid)) {
      deck.cards.firstWhere((element) => element.uuid == uuid).qty++;
    } else {
      var dc = DeckCard(uuid: uuid, qty: 1);
      deck.cards.add(dc);
      var cs = await CardSet.fromUUID(uuid, Service.dataLoader.db);
      if (cs != null) cards[dc] = cs;
    }
  }

  Future deleteUUID(String uuid) async {
    if (deck.cards.any((element) => element.uuid == uuid)) {
      deck.cards.removeWhere((element) => element.uuid == uuid);
      cards.removeWhere((key, value) => key.uuid == uuid);
    }
  }

  Future setQty(String uuid, int qty) async {
    if (qty <= 0) {
      await deleteUUID(uuid);
    } else if (deck.cards.any((element) => element.uuid == uuid)) {
      deck.cards.firstWhere((element) => element.uuid == uuid).qty = qty;
    }
  }

  static String getDeckList(DeckCards? deck, DeckListType deckListType, bool lands) {
    if (deck == null) return '';
    var result = '';
    for (var card in deck.cards.entries) {
      if (!lands && card.value.types.contains('Land') && card.value.supertypes.contains('Basic')) continue;
      if (deckListType == DeckListType.namesAtomic) {
        result += '${card.key.qty} ${card.value.name}';
      }
      if (deckListType == DeckListType.namesSet) {
        result += '${card.key.qty} ${card.value.name} (${card.value.setCode})';
      }
      if (deckListType == DeckListType.namesAtomicNoQty) {
        result += card.value.name;
      }
      if (deckListType == DeckListType.namesSetNoQty) {
        result += '${card.value.name} (${card.value.setCode})';
      }
      if (deckListType == DeckListType.scryfallId) {
        result += '${card.value.identifiers.scryfallId} (${card.key.qty})';
      }
      result += '\n';
    }
    return result;
  }

  static Map<String, int> getTypes(DeckCards? deck) {
    if (deck == null) return {};
    Map<String, int> result = {};
    for (var card in deck.cards.values) {
      for (var type in card.types) {
        result[type] = (result[type] ?? 0) + 1;
      }
    }
    return result;
  }
}
