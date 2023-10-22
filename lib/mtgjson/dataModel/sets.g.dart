// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MtgSets _$MtgSetsFromJson(Map<String, dynamic> json) => MtgSets(
      JsonMeta.fromJson(json['meta'] as Map<String, dynamic>),
      (json['data'] as List<dynamic>)
          .map((e) => MtgSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MtgSetsToJson(MtgSets instance) => <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
