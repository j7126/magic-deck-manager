import 'package:json_annotation/json_annotation.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/json_meta.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/set.dart';

part 'sets.g.dart';

@JsonSerializable(explicitToJson: true)
class MtgSets {
  MtgSets(this.meta, this.data);

  JsonMeta meta;
  List<MtgSet> data;

  factory MtgSets.fromJson(Map<String, dynamic> json) => _$MtgSetsFromJson(json);

  Map<String, dynamic> toJson() => _$MtgSetsToJson(this);
}