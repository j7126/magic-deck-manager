// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchable_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchableCard _$SearchableCardFromJson(Map<String, dynamic> json) =>
    SearchableCard(
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      subtypes:
          (json['subtypes'] as List<dynamic>).map((e) => e as String).toList(),
      supertypes: (json['supertypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      colorIdentity: (json['colorIdentity'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      leadershipSkills: json['leadershipSkills'] == null
          ? null
          : LeadershipSkills.fromJson(
              json['leadershipSkills'] as Map<String, dynamic>),
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    )
      ..cardSearchString = json['cardSearchString'] as String
      ..cardSearchStringWords = (json['cardSearchStringWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

Map<String, dynamic> _$SearchableCardToJson(SearchableCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'types': instance.types,
      'subtypes': instance.subtypes,
      'supertypes': instance.supertypes,
      'colorIdentity': instance.colorIdentity,
      'leadershipSkills': instance.leadershipSkills?.toJson(),
      'keywords': instance.keywords,
      'cardSearchString': instance.cardSearchString,
      'cardSearchStringWords': instance.cardSearchStringWords,
    };
