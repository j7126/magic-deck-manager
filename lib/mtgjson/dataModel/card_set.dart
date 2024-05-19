/*
 * Magic Deck Manager
 * card_set.dart
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

import 'package:json_annotation/json_annotation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/identifiers.dart';
import 'package:sqflite/sqflite.dart';

part 'card_set.g.dart';

@JsonSerializable(explicitToJson: true)
class CardSet {
  CardSet({
    required this.name,
    required this.identifiers,
    required this.borderColor,
    required this.colorIdentity,
    required this.colors,
    required this.finishes,
    required this.frameVersion,
    this.keywords,
    required this.language,
    required this.layout,
    this.loyalty,
    this.manaValue,
    this.manaCost,
    this.rarity,
    required this.setCode,
    required this.subtypes,
    required this.supertypes,
    required this.type,
    required this.types,
    this.text,
    this.power,
    this.toughness,
    required this.uuid,
  });

  String name;
  Identifiers identifiers;
  String borderColor;
  List<String> colorIdentity;
  List<String> colors;
  List<String> finishes;
  String frameVersion;
  List<String>? keywords;
  String language;
  String layout;
  String? loyalty;
  double? manaValue;
  String? manaCost;
  String? rarity;
  String setCode;
  List<String> subtypes;
  List<String> supertypes;
  String type;
  List<String> types;
  String? text;
  String? power;
  String? toughness;
  String uuid;

  factory CardSet.fromJson(Map<String, dynamic> json) => _$CardSetFromJson(json);

  Map<String, dynamic> toJson() => _$CardSetToJson(this);

  static Future<CardSet?> fromUUID(String uuid, Database db) async {
    List<Map<String, dynamic>> data = await db.query(
      'set_cards',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (data.isEmpty) {
      return null;
    }
    return CardSet.fromSqlite(data.first, db);
  }

  static Future<CardSet> fromSqlite(Map<String, dynamic> sqlite, DatabaseExecutor db) async {
    Map<String, dynamic> data = Map.of(sqlite);
    String uuid = data['uuid'];
    List<Map<String, dynamic>> identifiers = await db.query(
      'identifiers',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    data['identifiers'] = identifiers.first;
    data['colorIdentity'] = data['colorIdentity'].toString().split(', ');
    data['colors'] = data['colors'].toString().split(', ');
    data['finishes'] = data['finishes'].toString().split(', ');
    data['keywords'] = data['keywords'].toString().split(', ');
    data['subtypes'] = data['subtypes'].toString().split(', ');
    data['supertypes'] = data['supertypes'].toString().split(', ');
    data['types'] = data['types'].toString().split(', ');
    return CardSet.fromJson(data);
  }
}
