// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_set_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllSetCards _$AllSetCardsFromJson(Map<String, dynamic> json) => AllSetCards(
      JsonMeta.fromJson(json['meta'] as Map<String, dynamic>),
      (json['data'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CardSet.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AllSetCardsToJson(AllSetCards instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data.map((k, e) => MapEntry(k, e.toJson())),
    };
