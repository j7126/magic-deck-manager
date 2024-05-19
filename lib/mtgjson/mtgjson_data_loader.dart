/*
 * Magic Deck Manager
 * mtgjson_data_loader.dart
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

import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/searchable_cards.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/set.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/sets.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad) {
    loadAll();
  }

  Function onLoad;

  bool loaded = false;

  late SearchableCards searchableCards;
  late MtgSets sets;
  late Database db;

  Future loadAll() async {
    await loadSearchableCards();
    await loadSets();
    await loadSqlite();
    loaded = true;
    onLoad();
  }

  Future loadSearchableCards() async {
    String json = await rootBundle.loadString('data/cards_searchable.json');
    Map<String, dynamic> data = await compute((j) => jsonDecode(j), json);
    searchableCards = SearchableCards.fromJson(data);
  }

  Future loadSets() async {
    String json = await rootBundle.loadString('data/SetList.json');
    Map<String, dynamic> data = await compute((j) => jsonDecode(j), json);
    sets = MtgSets.fromJson(data);
  }

  Future<List<CardSet>> cardsByName(String name) async {
    List<Map<String, dynamic>> maps = await db.query(
      'set_cards',
      where: 'name = ?',
      whereArgs: [name],
    );

    return await Future.wait(maps.map((e) => CardSet.fromSqlite(e, db)));
  }

  Future<List<CardSet>> cardsByNames(Iterable<String> names) async {
    var names0 = names.toList();
    List<Map<String, dynamic>> maps = await db.query(
      'set_cards',
      where: "name IN (${names0.map((e) => '?').join(',')})",
      whereArgs: names0,
    );

    return await Future.wait(maps.map((e) => CardSet.fromSqlite(e, db)));
  }

  Future<CardSet?> cardByScryfallId(String id) async {
    List<Map<String, dynamic>> identifiers = await db.query(
      'identifiers',
      where: 'scryfallId = ?',
      whereArgs: [id],
    );
    var uuid = identifiers.firstOrNull?["uuid"];
    if (uuid == null) {
      return null;
    }
    return cardByUUID(uuid);
  }

  Future<CardSet?> cardByUUID(String uuid) async {
    List<Map<String, dynamic>> maps = await db.query(
      'set_cards',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (maps.isEmpty) {
      return null;
    }

    return await CardSet.fromSqlite(maps.first, db);
  }

  Future<MtgSet?> setByCode(String code) async {
    List<Map<String, dynamic>> maps = await db.query(
      'sets',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (maps.isEmpty) {
      return null;
    }

    return MtgSet.fromJson(maps.first);
  }

  Future moveSqliteFile(String path) async {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load("data/AllPrintings.sqlite");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);

    log("mtg database extracted.");
  }

  Future loadSqlite() async {
    log("loading mtg database.");

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "AllPrintings.sqlite");

    var exists = await databaseExists(path);
    if (!exists) {
      await moveSqliteFile(path);
    }

    db = await openDatabase(path, readOnly: true);

    var meta = await db.query("meta");

    if (meta[0]["date"] != searchableCards.meta.date) {
      await moveSqliteFile(path);
      await db.close();
      db = await openDatabase(path, readOnly: true);
    }
  }
}
