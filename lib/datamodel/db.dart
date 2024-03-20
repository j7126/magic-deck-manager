
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