// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DeckCard _$DeckCardFromJson(Map<String, dynamic> json) {
  return _DeckCard.fromJson(json);
}

/// @nodoc
mixin _$DeckCard {
  String get uuid => throw _privateConstructorUsedError;
  set uuid(String value) => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  set qty(int value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeckCardCopyWith<DeckCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckCardCopyWith<$Res> {
  factory $DeckCardCopyWith(DeckCard value, $Res Function(DeckCard) then) =
      _$DeckCardCopyWithImpl<$Res, DeckCard>;
  @useResult
  $Res call({String uuid, int qty});
}

/// @nodoc
class _$DeckCardCopyWithImpl<$Res, $Val extends DeckCard>
    implements $DeckCardCopyWith<$Res> {
  _$DeckCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? qty = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _value.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DeckCardCopyWith<$Res> implements $DeckCardCopyWith<$Res> {
  factory _$$_DeckCardCopyWith(
          _$_DeckCard value, $Res Function(_$_DeckCard) then) =
      __$$_DeckCardCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uuid, int qty});
}

/// @nodoc
class __$$_DeckCardCopyWithImpl<$Res>
    extends _$DeckCardCopyWithImpl<$Res, _$_DeckCard>
    implements _$$_DeckCardCopyWith<$Res> {
  __$$_DeckCardCopyWithImpl(
      _$_DeckCard _value, $Res Function(_$_DeckCard) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? qty = null,
  }) {
    return _then(_$_DeckCard(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _value.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_DeckCard implements _DeckCard {
  _$_DeckCard({required this.uuid, required this.qty});

  factory _$_DeckCard.fromJson(Map<String, dynamic> json) =>
      _$$_DeckCardFromJson(json);

  @override
  String uuid;
  @override
  int qty;

  @override
  String toString() {
    return 'DeckCard(uuid: $uuid, qty: $qty)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DeckCardCopyWith<_$_DeckCard> get copyWith =>
      __$$_DeckCardCopyWithImpl<_$_DeckCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DeckCardToJson(
      this,
    );
  }
}

abstract class _DeckCard implements DeckCard {
  factory _DeckCard({required String uuid, required int qty}) = _$_DeckCard;

  factory _DeckCard.fromJson(Map<String, dynamic> json) = _$_DeckCard.fromJson;

  @override
  String get uuid;
  set uuid(String value);
  @override
  int get qty;
  set qty(int value);
  @override
  @JsonKey(ignore: true)
  _$$_DeckCardCopyWith<_$_DeckCard> get copyWith =>
      throw _privateConstructorUsedError;
}
