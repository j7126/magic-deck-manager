/*
 * Magic Deck Manager
 * searchable_card.dart
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
import 'package:magic_deck_manager/mtgjson/dataModel/leadership_skills.dart';
import 'package:string_normalizer/string_normalizer.dart';

part 'searchable_card.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchableCard {
  SearchableCard({
    required this.name,
    required this.types,
    required this.subtypes,
    required this.supertypes,
    required this.colorIdentity,
    this.leadershipSkills,
    this.keywords,
  }) {
    cardSearchString = filterStringForSearch(name);
    cardSearchStringWords = cardSearchString.split(' ');
  }

  String name;
  List<String> types;
  List<String> subtypes;
  List<String> supertypes;
  List<String> colorIdentity;
  LeadershipSkills? leadershipSkills;
  List<String>? keywords;

  late String cardSearchString;
  late List<String> cardSearchStringWords;

  factory SearchableCard.fromJson(Map<String, dynamic> json) => _$SearchableCardFromJson(json);

  Map<String, dynamic> toJson() => _$SearchableCardToJson(this);

  static RegExp cardSearchStringFilterEmptyRegex = RegExp('[\']');
  static RegExp cardSearchStringFilterSpaceRegex = RegExp('[-,. ]+');

  static String filterStringForSearch(String str) {
    str = str.toLowerCase().normalize();
    str = str.replaceAll(cardSearchStringFilterEmptyRegex, '');
    str = str.replaceAll(cardSearchStringFilterSpaceRegex, ' ');
    return str;
  }

  int getWordMatches(List<String> words) {
    if (cardSearchStringWords.isEmpty) {
      return 0;
    }
    var offset = words.indexWhere((element) => element == cardSearchStringWords.first);
    if (offset < 0) {
      return 0;
    }
    int i = 1;
    while (i < cardSearchStringWords.length && i + offset < words.length) {
      if (cardSearchStringWords[i] != words[i]) {
        break;
      }
      i++;
    }
    return i;
  }

  static List<String> filterTypes = [
    "Artifact",
    "Creature",
    "Enchantment",
    "Sorcery",
    "Instant",
    "Adventure",
    "Battle",
    "Dungeon",
    "Emblem",
    "Land",
    "Plane",
    "Planeswalker",
    "Scheme",
    "Token",
  ];
}
