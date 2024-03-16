// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchable_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchableCards _$SearchableCardsFromJson(Map<String, dynamic> json) =>
    SearchableCards(
      (json['data'] as List<dynamic>)
          .map((e) => SearchableCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      JsonMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchableCardsToJson(SearchableCards instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };
