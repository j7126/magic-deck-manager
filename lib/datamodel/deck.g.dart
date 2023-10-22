// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Deck _$$_DeckFromJson(Map<String, dynamic> json) => _$_Deck(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      colors: json['colors'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => DeckCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_DeckToJson(_$_Deck instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'colors': instance.colors,
      'cards': instance.cards.map((e) => e.toJson()).toList(),
    };
