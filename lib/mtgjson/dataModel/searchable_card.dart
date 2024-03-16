import 'package:json_annotation/json_annotation.dart';
import 'package:string_normalizer/string_normalizer.dart';

part 'searchable_card.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchableCard {
  SearchableCard({
    required this.name,
    required this.types,
  }) {
    cardSearchString = filterStringForSearch(name);
    cardSearchStringWords = cardSearchString.split(' ');
  }

  String name;
  List<String> types;

  late String cardSearchString;
  late List<String> cardSearchStringWords;

  factory SearchableCard.fromJson(Map<String, dynamic> json) => _$SearchableCardFromJson(json);

  Map<String, dynamic> toJson() => _$SearchableCardToJson(this);

  static RegExp cardSearchStringFilterEmptyRegex = RegExp('[\']');
  static RegExp cardSearchStringFilterSpaceRegex = RegExp('[-,. ]+');

  static String filterStringForSearch(String str) {
    str = str.toLowerCase().normalize();
    str = str.replaceAll(cardSearchStringFilterEmptyRegex, '');
    str = str.replaceAll(cardSearchStringFilterSpaceRegex, ' ');
    return str;
  }

  int getWordMatches(List<String> words) {
    if (cardSearchStringWords.isEmpty) {
      return 0;
    }
    var offset = words.indexWhere((element) => element == cardSearchStringWords.first);
    if (offset < 0) {
      return 0;
    }
    int i = 1;
    while (i < cardSearchStringWords.length && i + offset < words.length) {
      if (cardSearchStringWords[i] != words[i]) {
        break;
      }
      i++;
    }
    return i;
  }

  static List<String> filterTypes = [
    "Artifact",
    "Creature",
    "Enchantment",
    "Sorcery",
    "Instant",
    "Adventure",
    "Battle",
    "Dungeon",
    "Emblem",
    "Land",
    "Plane",
    "Planeswalker",
    "Scheme",
    "Token",
  ];
}
