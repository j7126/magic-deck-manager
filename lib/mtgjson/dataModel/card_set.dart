import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/identifiers.dart';
import 'package:sqflite/sqflite.dart';

part 'card_set.freezed.dart';
part 'card_set.g.dart';

@freezed
class CardSet with _$CardSet {
  @JsonSerializable(explicitToJson: true)
  const factory CardSet({
    required String name,
    required Identifiers identifiers,
    required List<String> availability,
    required String borderColor,
    required List<String> colorIdentity,
    required List<String> colors,
    required List<String> finishes,
    required String frameVersion,
    required String language,
    required String layout,
    double? manaValue,
    String? manaCost,
    String? rarity,
    required String setCode,
    required List<String> subtypes,
    required List<String> supertypes,
    required String type,
    required List<String> types,
    String? text,
    String? power,
    String? toughness,
    required String uuid,
  }) = _CardSet;

  factory CardSet.fromJson(Map<String, dynamic> json) => _$CardSetFromJson(json);

  static Future<CardSet?> fromUUID(String uuid, Database db) async {
    List<Map<String, dynamic>> data = await db.query(
      'cards',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (data.isEmpty) {
      return null;
    }
    return CardSet.fromSqlite(data.first, db);
  }

  static Future<CardSet> fromSqlite(Map<String, dynamic> sqlite, Database db) async {
    Map<String, dynamic> data = Map.of(sqlite);
    String uuid = data['uuid'];
    List<Map<String, dynamic>> identifiers = await db.query(
      'cardIdentifiers',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    data['identifiers'] = identifiers.first;
    data['availability'] = data['availability'].toString().split(', ');
    data['colorIdentity'] = data['colorIdentity'].toString().split(', ');
    data['colors'] = data['colors'].toString().split(', ');
    data['finishes'] = data['finishes'].toString().split(', ');
    data['subtypes'] = data['subtypes'].toString().split(', ');
    data['supertypes'] = data['supertypes'].toString().split(', ');
    data['types'] = data['types'].toString().split(', ');
    return CardSet.fromJson(data);
  }
}
