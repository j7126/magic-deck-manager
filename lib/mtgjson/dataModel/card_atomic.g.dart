// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_atomic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CardAtomic _$$_CardAtomicFromJson(Map<String, dynamic> json) =>
    _$_CardAtomic(
      name: json['name'] as String,
      colorIdentity: (json['colorIdentity'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      colors:
          (json['colors'] as List<dynamic>).map((e) => e as String).toList(),
      layout: json['layout'] as String,
      manaValue: (json['manaValue'] as num).toDouble(),
      mamaCost: json['mamaCost'] as String?,
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
    );

Map<String, dynamic> _$$_CardAtomicToJson(_$_CardAtomic instance) =>
    <String, dynamic>{
      'name': instance.name,
      'colorIdentity': instance.colorIdentity,
      'colors': instance.colors,
      'layout': instance.layout,
      'manaValue': instance.manaValue,
      'mamaCost': instance.mamaCost,
      'subtypes': instance.subtypes,
      'supertypes': instance.supertypes,
      'type': instance.type,
      'types': instance.types,
      'text': instance.text,
      'power': instance.power,
      'toughness': instance.toughness,
    };
