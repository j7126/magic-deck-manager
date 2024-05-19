/*
 * Magic Deck Manager
 * about_page.dart
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

import 'package:magic_deck_manager/icons/custom_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic_deck_manager/ui/nav.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? packageInfo;

  void setup() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavMenu(),
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text("About"),
        titleSpacing: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon/logo.svg',
                          height: 32,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Opacity(
                              opacity: 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Magic Deck Manager',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    '© 2023 Jefferey Neuffer',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        const Opacity(
                          opacity: 0.5,
                          child: Icon(
                            Icons.info_outline,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Opacity(
                              opacity: 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App Version',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    '${packageInfo?.version ?? '-.-.-'} (${packageInfo?.buildNumber ?? ''})',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://j7126.dev/projects/magic-deck-manager')),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.home_outlined,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Home Page',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'https://jefferey.dev/projects/magic-deck-manager',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://github.com/j7126/magic-deck-manager/issues')),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.bug_report,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Report an issue',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'https://github.com/j7126/magic-deck-manager/issues',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://github.com/j7126/magic-deck-manager')),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              CustomIcons.github_circled,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'View on GitHub',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'https://github.com/j7126/magic-deck-manager',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://github.com/j7126/magic-deck-manager/blob/main/CREDITS.md')),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Credits',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'https://github.com/j7126/magic-deck-manager/blob/main/CREDITS.md',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://github.com/j7126/magic-deck-manager/blob/main/LICENSE.txt')),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.gavel_outlined,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'License',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'GNU Affero General Public License',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Opacity(
                    opacity: 0.3,
                    child: Text(
                      "Magic Deck Manager Copyright (C) 2024 Jefferey Neuffer.\nThis program is free software, licensed under GNU AGPL v3 or any later version.\n\nPortions of this app contains information and images related to Magic: The Gathering. Card metadata is bundled with the app, and card images may be fetched from Scryfall. Wizards of the Coast, Magic: The Gathering, and their logos, in addtion to the literal and graphical information presented about Magic: The Gathering, including card images, names, mana symbols and other associated metadata, is copyright Wizards of the Coast, LLC. All rights reserved. This app is not produced by or endorsed by Wizards of the Coast.",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
