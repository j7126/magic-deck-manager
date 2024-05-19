/*
 * Magic Deck Manager
 * deck_cards.dart
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

import 'package:collection/collection.dart';
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

  DeckCard? getDeckCardByUUID(String uuid) {
    return deck.cards.firstWhereOrNull((element) => element.uuid == uuid);
  }

  void addToCardQty(String uuid, int qty) {
    var dc = getDeckCardByUUID(uuid);
    if (dc != null) {
      setQty(dc.uuid, dc.qty + qty);
    } else {
      addUUID(uuid);
      var dc = getDeckCardByUUID(uuid);
      if (dc != null) {
        setQty(dc.uuid, dc.qty + qty - 1);
      }
    }
  }

  static String getDeckList(DeckCards? deck, DeckListType deckListType, bool lands) {
    if (deck == null) return '';
    var result = '';
    for (var card in deck.cards.entries) {
      if (!lands && card.value.types.contains('Land') && card.value.supertypes.contains('Basic')) continue;
      switch (deckListType) {
        case DeckListType.namesAtomic:
          result += '${card.key.qty} ${card.value.name}';
          break;
        case DeckListType.namesSet:
          result += '${card.key.qty} ${card.value.name} (${card.value.setCode})';
          break;
        case DeckListType.namesAtomicNoQty:
          result += card.value.name;
          break;
        case DeckListType.namesSetNoQty:
          result += '${card.value.name} (${card.value.setCode})';
          break;
        case DeckListType.scryfallId:
          result += '${card.value.identifiers.scryfallId} (${card.key.qty})';
          break;
        default:
      }
      result += '\n';
    }
    return result;
  }

  static Future<List<bool>?> importDeckList(DeckCards? deck, DeckListType deckListType, String list) async {
    if (deck == null) return null;
    List<bool> result = [];
    for (var line in list.split('\n')) {
      if (line.isEmpty || line == ' ') {
        result.add(true);
        continue;
      }
      if (deckListType == DeckListType.namesAtomic) {
        var match = RegExp(r'([0-9]*) (.*)').allMatches(line).firstOrNull;
        var qty = int.tryParse(match?.group(1) ?? '0');
        var name = match?.group(2);
        if (match == null || name == null || qty == null || qty <= 0) {
          result.add(false);
          continue;
        }
        var card = (await Service.dataLoader.cardsByName(name)).firstOrNull;
        if (card == null) {
          result.add(false);
          continue;
        }
        result.add(true);
        deck.addToCardQty(card.uuid, qty);
      } else if (deckListType == DeckListType.namesSet) {
        var match = RegExp(r'([0-9]*) (.*) \((.*)\)').allMatches(line).firstOrNull;
        var qty = int.tryParse(match?.group(1) ?? '0');
        var name = match?.group(2);
        var setCode = match?.group(3);
        if (match == null || name == null || qty == null || qty <= 0 || setCode == null) {
          result.add(false);
          continue;
        }
        var card = (await Service.dataLoader.cardsByName(name)).firstWhereOrNull((element) => element.setCode == setCode);
        if (card == null) {
          result.add(false);
          continue;
        }
        result.add(true);
        deck.addToCardQty(card.uuid, qty);
      } else if (deckListType == DeckListType.namesAtomicNoQty) {
        var card = (await Service.dataLoader.cardsByName(line)).firstOrNull;
        if (card == null) {
          result.add(false);
          continue;
        }
        result.add(true);
        deck.addUUID(card.uuid);
      } else if (deckListType == DeckListType.namesSetNoQty) {
        var match = RegExp(r'(.*) \((.*)\)').allMatches(line).firstOrNull;
        var name = match?.group(1);
        var setCode = match?.group(2);
        if (match == null || name == null || setCode == null) {
          result.add(false);
          continue;
        }
        var card = (await Service.dataLoader.cardsByName(name)).firstWhereOrNull((element) => element.setCode == setCode);
        if (card == null) {
          result.add(false);
          continue;
        }
        result.add(true);
        deck.addUUID(card.uuid);
      } else if (deckListType == DeckListType.scryfallId) {
        var match = RegExp(r'(.*) \(([0-9])\)').allMatches(line).firstOrNull;
        var id = match?.group(1);
        var qty = int.tryParse(match?.group(2) ?? '0');
        if (match == null || id == null || qty == null || qty <= 0) {
          result.add(false);
          continue;
        }
        var card = (await Service.dataLoader.cardByScryfallId(id));
        if (card == null) {
          result.add(false);
          continue;
        }
        result.add(true);
        deck.addToCardQty(card.uuid, qty);
      }
    }
    return result;
  }

  static Map<String, int> getTypes(DeckCards? deck) {
    if (deck == null) return {};
    Map<String, int> result = {};
    for (var card in deck.cards.entries) {
      for (var type in card.value.types) {
        result[type] = (result[type] ?? 0) + card.key.qty;
      }
    }
    return result;
  }
}
