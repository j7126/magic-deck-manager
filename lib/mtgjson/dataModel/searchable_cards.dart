/*
 * Magic Deck Manager
 * searchable_cards.dart
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
import 'package:magic_deck_manager/mtgjson/dataModel/json_meta.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/searchable_card.dart';

part 'searchable_cards.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchableCards {
  SearchableCards(this.data, this.meta);

  List<SearchableCard> data;

  JsonMeta meta;

  factory SearchableCards.fromJson(Map<String, dynamic> json) => _$SearchableCardsFromJson(json);

  Map<String, dynamic> toJson() => _$SearchableCardsToJson(this);

  List<SearchableCard> searchCards(String query) {
    var finalSearchStr = SearchableCard.filterStringForSearch(query.trim());
    var searchStrWords = finalSearchStr.split(' ');
    var cards = data.where(
      (card) {
        return card.cardSearchString.contains(finalSearchStr);
      },
    ).toList();
    cards.sort((a, b) {
      var wordMatchesA = a.getWordMatches(searchStrWords);
      var wordMatchesB = b.getWordMatches(searchStrWords);
      if (wordMatchesA != wordMatchesB) {
        return wordMatchesB - wordMatchesA;
      } else {
        return a.name.length.compareTo(b.name.length);
      }
    });
    return cards;
  }
}
