import 'package:json_annotation/json_annotation.dart';

part 'json_meta.g.dart';

@JsonSerializable(explicitToJson: true)
class JsonMeta {
  JsonMeta(this.date, this.version);

  String date;
  String version;

  factory JsonMeta.fromJson(Map<String, dynamic> json) => _$JsonMetaFromJson(json);

  Map<String, dynamic> toJson() => _$JsonMetaToJson(this);
}