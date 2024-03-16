// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchable_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchableCard _$SearchableCardFromJson(Map<String, dynamic> json) =>
    SearchableCard(
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
    )
      ..cardSearchString = json['cardSearchString'] as String
      ..cardSearchStringWords = (json['cardSearchStringWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

Map<String, dynamic> _$SearchableCardToJson(SearchableCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'types': instance.types,
      'cardSearchString': instance.cardSearchString,
      'cardSearchStringWords': instance.cardSearchStringWords,
    };
