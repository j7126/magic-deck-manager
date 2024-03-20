// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deck _$DeckFromJson(Map<String, dynamic> json) => Deck(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      colors: json['colors'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => DeckCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String?,
    );

Map<String, dynamic> _$DeckToJson(Deck instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'colors': instance.colors,
      'cards': instance.cards.map((e) => e.toJson()).toList(),
      'format': instance.format,
    };
