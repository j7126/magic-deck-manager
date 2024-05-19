/*
 * Magic Deck Manager
 * nav.dart
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
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/icons/custom_icons.dart';

class _Destination {
  const _Destination({required this.label, required this.icon, required this.selectedIcon, required this.route});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

class NavMenu extends StatelessWidget {
  const NavMenu({super.key});

  static const List<_Destination> _destinations = [
    _Destination(
      label: "Decks",
      icon: CustomIcons.deck_outlined,
      selectedIcon: CustomIcons.deck_filled,
      route: "/decks",
    ),
    _Destination(
      label: "Search Cards",
      icon: CustomIcons.cards_outlined,
      selectedIcon: CustomIcons.cards_filled,
      route: "/cards",
    ),
    _Destination(
      label: "Settings",
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: "/settings",
    ),
    _Destination(
      label: "About",
      icon: Icons.info_outline,
      selectedIcon: Icons.info,
      route: "/about",
    ),
  ];

  static List<String> get routes {
    return _destinations.map((e) => e.route).toList();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (value) => Navigator.of(context).pushReplacementNamed(_destinations[value].route),
      selectedIndex: _destinations.indexWhere((element) => ModalRoute.of(context)?.settings.name == element.route),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 20),
          child: Text(
            Service.appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ..._destinations.map(
          (destination) => NavigationDrawerDestination(
            label: Text(destination.label),
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
          ),
        ),
      ],
    );
  }
}
