import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:magic_deck_manager/datamodel/color.dart';
import 'package:magic_deck_manager/datamodel/deck_card.dart';
import 'package:magic_deck_manager/service/static_service.dart';

part 'deck.g.dart';

@JsonSerializable(explicitToJson: true)
class Deck {
  Deck({
    required this.uuid,
    required this.name,
    required this.description,
    required this.colors,
    required this.cards,
    this.format,
  });

  final String uuid;
  String name;
  String description;
  String colors;
  List<DeckCard> cards;
  String? format;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  Map<String, dynamic> toJson() => _$DeckToJson(this);

  static _asJson(Deck deck) {
    var d = deck.toJson();
    d.remove('cards');
    return d;
  }

  static Future update(Deck deck) async {
    await Service.db.update(
      'decks',
      Deck._asJson(deck),
      where: 'uuid = ?',
      whereArgs: [deck.uuid],
    );
    await Service.db.delete(
      'cards',
      where: 'deck = ?',
      whereArgs: [deck.uuid],
    );
    await Future.wait(
      deck.cards.map(
        (x) async {
          try {
            await Service.db.insert(
              'cards',
              {
                'deck': deck.uuid,
                'uuid': x.uuid,
                'qty': x.qty,
                'commander': x.commander ? 1 : 0,
              },
            );
          } catch (e) {}
        },
      ),
    );
  }

  static Future insert(Deck deck) async {
    await Service.db.insert('decks', Deck._asJson(deck));
    await Future.wait(
      deck.cards.map(
        (x) => Service.db.insert(
          'cards',
          {
            'deck': deck.uuid,
            'uuid': x.uuid,
            'qty': x.qty,
            'commander': x.commander ? 1 : 0,
          },
        ),
      ),
    );
  }

  static Future save(Deck? deck) async {
    if (deck == null) return;
    if ((await Service.db.query(
      'decks',
      where: 'uuid = ?',
      whereArgs: [deck.uuid],
    ))
        .isNotEmpty) {
      // if exists update
      await Deck.update(deck);
    } else {
      // does not exist, insert
      await Deck.insert(deck);
    }
  }

  static Future deleteUUID(String? deck) async {
    if (deck == null) return;
    await Service.db.delete(
      'cards',
      where: 'deck = ?',
      whereArgs: [deck],
    );
    await Service.db.delete(
      'decks',
      where: 'uuid = ?',
      whereArgs: [deck],
    );
  }

  static Future delete(Deck? deck) async {
    await deleteUUID(deck?.uuid);
  }

  static Future<Deck> fromUUID(String uuid) async {
    List<Map<String, dynamic>> deck = await Service.db.query(
      'decks',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    Map<String, dynamic> data = Map.of(deck.first);
    List<Map<String, dynamic>> cards = await Service.db.query(
      'cards',
      where: 'deck = ?',
      whereArgs: [uuid],
    );
    data['cards'] = cards
        .map(
          (e) => DeckCard(
            uuid: e['uuid'].toString(),
            qty: int.parse(e['qty'].toString()),
            commander: int.parse(e['commander']?.toString() ?? "0") > 0,
          ).toJson(),
        )
        .toList();
    return Deck.fromJson(data);
  }

  static Set<ManaColor> getColorSet(Deck? deck) {
    if (deck == null) {
      return <ManaColor>{};
    }
    Set<ManaColor> set = {};
    for (int i = 0; i < deck.colors.length; i++) {
      set.add(ManaColor.fromStr(deck.colors[i]));
    }
    return set;
  }

  static void setColorSet(Deck? deck, Set<ManaColor> cs) {
    if (deck == null) {
      return;
    }
    String s = '';
    for (var c in cs) {
      s += c.str;
    }
    deck.colors = s;
  }

  static Color? getBgColor(Deck? deck) {
    if (deck == null) return null;
    var colors = Deck.getColorSet(deck);
    var bgOpacity = 40;
    return colors.length < 2 && colors.isNotEmpty ? ManaColor.getColor(colors.first, opacity: bgOpacity) : null;
  }

  static LinearGradient? getBgGradient(Deck? deck) {
    if (deck == null) return null;
    var colors = Deck.getColorSet(deck);
    var bgOpacity = 40;
    return colors.length >= 2
        ? LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: colors.map((c) => ManaColor.getColor(c, opacity: bgOpacity)).toList(),
          )
        : null;
  }

  static Future refreshCards(Deck? deck) async {
    if (deck == null) return;
    List<Map<String, dynamic>> cards = await Service.db.query(
      'cards',
      where: 'deck = ?',
      whereArgs: [deck.uuid],
    );
    deck.cards = cards
        .map(
          (e) => DeckCard(
            uuid: e['uuid'].toString(),
            qty: int.parse(e['qty'].toString()),
            commander: int.parse(e['commander']?.toString() ?? "0") > 0,
          ),
        )
        .toList();
  }

  static Future<List<Deck>> getDecks() async {
    List<Map<String, dynamic>> d = await Service.db.query('decks');
    return await Future.wait(d.map((e) => Deck.fromUUID(e['uuid'].toString())));
  }
}
