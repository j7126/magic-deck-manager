import 'package:flutter/material.dart';
import 'package:magic_deck_manager/pages/about_page.dart';
import 'package:magic_deck_manager/pages/settings_page.dart';
import 'package:magic_deck_manager/service/settings.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/pages/decks_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:magic_deck_manager/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_deck_manager/pages/error_page.dart';
import 'package:magic_deck_manager/pages/home_page.dart';
import 'package:magic_deck_manager/pages/cards_page.dart';
import 'package:magic_deck_manager/pages/loading_page.dart';
import 'dart:io';

void main() {
  if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool dbReady = false;
  bool settingsReady = false;
  bool get ready => Service.dataLoader.loaded && dbReady && settingsReady;

  void mtgDataOnLoad() {
    setState(() {});
  }

  void loadDb() async {
    Service.db = await openDatabase(
      join(await getDatabasesPath(), 'decks.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE decks(uuid TEXT PRIMARY KEY, name TEXT, description TEXT, colors TEXT)',
        );
        await db.execute(
          'CREATE TABLE cards(deck TEXT, uuid TEXT, qty INT, primary key (deck, uuid))',
        );
      },
      version: 1,
    );
    setState(() {
      dbReady = true;
    });
  }

  void loadSettingsService() async {
    Service.settingsService = await SettingsService.build();
    setState(() {
      settingsReady = true;
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    Service.dataLoader = MTGDataLoader(mtgDataOnLoad);
    loadDb();
    loadSettingsService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Widget loading = LoadingPage();

    return MaterialApp(
      title: Service.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        var name = settings.name;

        if (name == "/") {
          name = "/decks";
        }

        switch (name) {
          case "/home":
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ready ? const HomePage() : loading,
              settings: settings,
            );
          case "/decks":
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ready ? const DecksPage() : loading,
              settings: settings,
            );
          case "/cards":
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ready ? const CardsPage() : loading,
              settings: settings,
            );
          case "/settings":
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ready ? const SettingsPage() : loading,
              settings: settings,
            );
          case "/about":
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ready ? const AboutPage() : loading,
              settings: settings,
            );
          default:
            return PageRouteBuilder(pageBuilder: (_, __, ___) => const ErrorPage());
        }
      },
      initialRoute: "/decks",
    );
  }
}
