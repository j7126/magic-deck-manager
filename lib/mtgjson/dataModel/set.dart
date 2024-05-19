/*
 * Magic Deck Manager
 * set.dart
 * 
 * Copyright (C) 2023 - 2024 Jefferey Neuffer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';

part 'set.g.dart';

@JsonSerializable(explicitToJson: true)
class MtgSet {
  MtgSet({
    required this.baseSetSize,
    required this.code,
    required this.isFoilOnly,
    required this.isOnlineOnly,
    required this.keyruneCode,
    required this.name,
    required this.releaseDate,
    required this.totalSetSize,
    required this.type,
  });

  int baseSetSize;
  String code;
  bool isFoilOnly;
  bool isOnlineOnly;
  String keyruneCode;
  String name;
  String releaseDate;
  int totalSetSize;
  String type;

  factory MtgSet.fromJson(Map<String, dynamic> json) => _$MtgSetFromJson(json);

  Map<String, dynamic> toJson() => _$MtgSetToJson(this);
}
