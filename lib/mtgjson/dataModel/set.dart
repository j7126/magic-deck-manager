import 'package:freezed_annotation/freezed_annotation.dart';

part 'set.freezed.dart';
part 'set.g.dart';

@freezed
class MtgSet with _$MtgSet {
  @JsonSerializable(explicitToJson: true)
  const factory MtgSet({
    required int baseSetSize,
    required String code,
    required bool isFoilOnly,
    required bool isOnlineOnly,
    required String keyruneCode,
    required String name,
    required String releaseDate,
    required int totalSetSize,
    required String type,
  }) = _MtgSet;

  factory MtgSet.fromJson(Map<String, dynamic> json) => _$MtgSetFromJson(json);
}
