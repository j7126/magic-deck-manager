import 'package:json_annotation/json_annotation.dart';

part 'deck_card.g.dart';

@JsonSerializable(explicitToJson: true)
class DeckCard {
  DeckCard({
    required this.uuid,
    required this.qty,
    this.commander = false,
  });

  String uuid;
  int qty;
  bool commander;

  factory DeckCard.fromJson(Map<String, dynamic> json) => _$DeckCardFromJson(json);

  Map<String, dynamic> toJson() => _$DeckCardToJson(this);
}
