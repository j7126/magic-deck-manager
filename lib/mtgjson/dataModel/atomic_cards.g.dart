// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atomic_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtomicCards _$AtomicCardsFromJson(Map<String, dynamic> json) => AtomicCards(
      JsonMeta.fromJson(json['meta'] as Map<String, dynamic>),
      (json['data'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => CardAtomic.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$AtomicCardsToJson(AtomicCards instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data
          .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
    };
