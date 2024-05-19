/*
 * Magic Deck Manager
 * identifiers.dart
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

part 'identifiers.g.dart';

@JsonSerializable(explicitToJson: true)
class Identifiers {
  Identifiers();

  String? cardKingdomEtchedId;
  String? cardKingdomFoilId;
  String? cardKingdomId;
  String? cardsphereId;
  String? mcmId;
  String? mcmMetaId;
  String? mtgArenaId;
  String? mtgjsonFoilVersionId;
  String? mtgjsonNonFoilVersionId;
  String? mtgjsonV4Id;
  String? mtgoFoilId;
  String? mtgoId;
  String? multiverseId;
  String? scryfallId;
  String? scryfallOracleId;
  String? scryfallIllustrationId;
  String? tcgplayerProductId;
  String? tcgplayerEtchedProductId;

  factory Identifiers.fromJson(Map<String, dynamic> json) =>
      _$IdentifiersFromJson(json);

  Map<String, dynamic> toJson() => _$IdentifiersToJson(this);
}
