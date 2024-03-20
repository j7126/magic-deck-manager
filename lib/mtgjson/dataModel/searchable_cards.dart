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
