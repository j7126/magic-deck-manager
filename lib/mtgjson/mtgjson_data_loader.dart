import 'dart:io';
import 'dart:convert';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/sets.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/atomic_cards.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad) {
    loadAll();
  }

  Function onLoad;

  bool loaded = false;

  late AtomicCards atomicCards;
  late MtgSets sets;
  late Database db;

  Future loadAll() async {
    await loadAtomicCards();
    await loadSets();
    await loadSqlite();
    loaded = true;
    onLoad();
  }

  Future<List<CardSet>> searchCards(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: limit,
      offset: offset,
    );

    return await Future.wait(maps.map((e) => CardSet.fromSqlite(e, db)));
  }

  Future<List<CardSet>> cardsByName(String name) async {
    List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name = ?',
      whereArgs: [name],
    );

    return await Future.wait(maps.map((e) => CardSet.fromSqlite(e, db)));
  }

  Future<CardSet?> cardByScryfallId(String id) async {
    List<Map<String, dynamic>> identifiers = await db.query(
      'cardIdentifiers',
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
      'cards',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (maps.isEmpty) {
      return null;
    }

    return await CardSet.fromSqlite(maps.first, db);
  }

  Future loadSqlite() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "AllPrintings.sqlite");

    var exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load("data/AllPrintings.sqlite");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    db = await openDatabase(path, readOnly: true);
  }

  Future loadAtomicCards() async {
    String json = await rootBundle.loadString('data/AtomicCards.json');
    Map<String, dynamic> data = jsonDecode(json);
    atomicCards = AtomicCards.fromJson(data);
  }

  Future loadSets() async {
    String json = await rootBundle.loadString('data/SetList.json');
    Map<String, dynamic> data = jsonDecode(json);
    sets = MtgSets.fromJson(data);
  }
}
