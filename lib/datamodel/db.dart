/*
 * Magic Deck Manager
 * db.dart
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

import 'package:magic_deck_manager/service/static_service.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Db {
  static int version = 2;

  static Future setupDb() async {
    Service.db = await openDatabase(
      join(await getDatabasesPath(), 'decks.db'),
      onCreate: (db, version) async {
        await db.execute(
          """CREATE TABLE decks(
            uuid TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            colors TEXT,
            format TEXT
          )""",
        );
        await db.execute(
          """CREATE TABLE cards(
            deck TEXT,
            uuid TEXT,
            qty INT,
            commander BOOLEAN,
            primary key (deck, uuid)
          )""",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (newVersion != version) {
          return;
        }

        var v = oldVersion;
        
        // v2
        if (v == 1) {
          v = 2;
          await db.execute("""ALTER TABLE cards ADD commander BOOLEAN""");
          await db.execute("""ALTER TABLE decks ADD format TEXT""");
        }
      },
      version: version,
    );
  }
}