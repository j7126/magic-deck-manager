import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_card.freezed.dart';
part 'deck_card.g.dart';

@unfreezed
class DeckCard with _$DeckCard {
  @JsonSerializable(explicitToJson: true)
  factory DeckCard({
    required String uuid,
    required int qty,
  }) = _DeckCard;

  factory DeckCard.fromJson(Map<String, dynamic> json) => _$DeckCardFromJson(json);
}
