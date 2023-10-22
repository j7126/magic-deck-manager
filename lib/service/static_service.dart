import 'package:magic_deck_manager/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_deck_manager/service/settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Service {
  static const appName = "Magic Deck Manager";

  static late SettingsService settingsService;

  static late Database db;
  static late MTGDataLoader dataLoader;
}