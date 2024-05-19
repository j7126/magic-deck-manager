/*
 * Magic Deck Manager
 * main.dart
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

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:magic_deck_manager/datamodel/db.dart';
import 'package:magic_deck_manager/ui/about/about_page.dart';
import 'package:magic_deck_manager/ui/settings/settings_page.dart';
import 'package:magic_deck_manager/service/settings.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/ui/decks/decks_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:magic_deck_manager/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_deck_manager/ui/error_page.dart';
import 'package:magic_deck_manager/ui/cards/cards_page.dart';
import 'package:magic_deck_manager/ui/loading_page.dart';
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
    await Db.setupDb();
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

    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: Service.appName,
        theme: ThemeData(
          colorScheme: lightDynamic ??
              ColorScheme.fromSeed(
                seedColor: Colors.green,
              ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic ?? ColorScheme.fromSeed(
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
    });
  }
}
