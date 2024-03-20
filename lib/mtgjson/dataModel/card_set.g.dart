// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardSet _$CardSetFromJson(Map<String, dynamic> json) => CardSet(
      name: json['name'] as String,
      identifiers:
          Identifiers.fromJson(json['identifiers'] as Map<String, dynamic>),
      borderColor: json['borderColor'] as String,
      colorIdentity: (json['colorIdentity'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      colors:
          (json['colors'] as List<dynamic>).map((e) => e as String).toList(),
      finishes:
          (json['finishes'] as List<dynamic>).map((e) => e as String).toList(),
      frameVersion: json['frameVersion'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      language: json['language'] as String,
      layout: json['layout'] as String,
      loyalty: json['loyalty'] as String?,
      manaValue: (json['manaValue'] as num?)?.toDouble(),
      manaCost: json['manaCost'] as String?,
      rarity: json['rarity'] as String?,
      setCode: json['setCode'] as String,
      subtypes:
          (json['subtypes'] as List<dynamic>).map((e) => e as String).toList(),
      supertypes: (json['supertypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: json['type'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      text: json['text'] as String?,
      power: json['power'] as String?,
      toughness: json['toughness'] as String?,
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$CardSetToJson(CardSet instance) => <String, dynamic>{
      'name': instance.name,
      'identifiers': instance.identifiers.toJson(),
      'borderColor': instance.borderColor,
      'colorIdentity': instance.colorIdentity,
      'colors': instance.colors,
      'finishes': instance.finishes,
      'frameVersion': instance.frameVersion,
      'keywords': instance.keywords,
      'language': instance.language,
      'layout': instance.layout,
      'loyalty': instance.loyalty,
      'manaValue': instance.manaValue,
      'manaCost': instance.manaCost,
      'rarity': instance.rarity,
      'setCode': instance.setCode,
      'subtypes': instance.subtypes,
      'supertypes': instance.supertypes,
      'type': instance.type,
      'types': instance.types,
      'text': instance.text,
      'power': instance.power,
      'toughness': instance.toughness,
      'uuid': instance.uuid,
    };
