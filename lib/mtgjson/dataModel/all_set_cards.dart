import 'package:json_annotation/json_annotation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/json_meta.dart';

part 'all_set_cards.g.dart';

@JsonSerializable(explicitToJson: true)
class AllSetCards {
  AllSetCards(this.meta, this.data);

  JsonMeta meta;
  Map<String, CardSet> data;

  factory AllSetCards.fromJson(Map<String, dynamic> json) =>
      _$AllSetCardsFromJson(json);

  Map<String, dynamic> toJson() => _$AllSetCardsToJson(this);

  List<CardSet> getByScryfallOracleId(String? id) {
    return id == null
        ? []
        : data.values
            .where((element) => element.identifiers.scryfallOracleId == id)
            .toList();
  }

  CardSet? getFirstByScryfallOracleId(String? id) {
    return id == null
        ? null
        : data.values.firstWhere(
            (element) => element.identifiers.scryfallOracleId == id);
  }
}
