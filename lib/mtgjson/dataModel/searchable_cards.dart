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
}
