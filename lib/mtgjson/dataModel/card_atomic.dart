import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_atomic.freezed.dart';
part 'card_atomic.g.dart';

@freezed
class CardAtomic with _$CardAtomic {
  @JsonSerializable(explicitToJson: true)
  const factory CardAtomic({
    required String name,
    required List<String> colorIdentity,
    required List<String> colors,
    required String layout,
    required double manaValue,
    String? mamaCost,
    required List<String> subtypes,
    required List<String> supertypes,
    required String type,
    required List<String> types,
    String? text,
    String? power,
    String? toughness,
  }) = _CardAtomic;

  factory CardAtomic.fromJson(Map<String, dynamic> json) => _$CardAtomicFromJson(json);

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
