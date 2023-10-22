import 'package:json_annotation/json_annotation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/json_meta.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_atomic.dart';

part 'atomic_cards.g.dart';

@JsonSerializable(explicitToJson: true)
class AtomicCards {
  AtomicCards(this.meta, this.data);

  JsonMeta meta;
  Map<String, List<CardAtomic>> data;

  factory AtomicCards.fromJson(Map<String, dynamic> json) => _$AtomicCardsFromJson(json);

  Map<String, dynamic> toJson() => _$AtomicCardsToJson(this);
}