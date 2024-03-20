// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckCard _$DeckCardFromJson(Map<String, dynamic> json) => DeckCard(
      uuid: json['uuid'] as String,
      qty: json['qty'] as int,
      commander: json['commander'] as bool? ?? false,
    );

Map<String, dynamic> _$DeckCardToJson(DeckCard instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'qty': instance.qty,
      'commander': instance.commander,
    };
