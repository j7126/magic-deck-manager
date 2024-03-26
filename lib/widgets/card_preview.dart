import 'dart:math';

import 'package:flutter/material.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_deck_manager/datamodel/deck_cards.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/searchable_card.dart';
import 'package:magic_deck_manager/pages/card_page.dart';
import 'package:magic_deck_manager/service/static_service.dart';
import 'package:magic_deck_manager/mtgjson/dataModel/card_set.dart';
import 'package:magic_deck_manager/widgets/card_text_preview.dart';

class CardPreview extends StatefulWidget {
  const CardPreview({
    super.key,
    required this.card,
    this.hideButtons = false,
    this.selectCard = false,
    this.dialogPreview = false,
    this.fadeText = true,
    this.isCommander = false,
    this.qty,
    this.qtyChanged,
    this.deckCards,
  });

  final dynamic card;
  final bool hideButtons;
  final bool selectCard;
  final bool dialogPreview;
  final bool fadeText;
  final bool isCommander;
  final int? qty;
  final Function(int)? qtyChanged;
  final DeckCards? deckCards;

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  bool ready = false;
  bool valid = true;
  bool isSingle = false;
  String imageUrl = '';
  String imageUrlLarge = '';

  List<CardSet> cardSets = [];

  void showDialogPreview() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 32),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.card == null
                          ? "Error fetching card"
                          : (widget.card is CardSet || widget.card is SearchableCard)
                              ? widget.card?.name
                              : cardSets.isNotEmpty
                                  ? cardSets.first.name
                                  : '',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: AspectRatio(
              aspectRatio: 488 / 680,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.background,
                      width: 2.0,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(constraints.maxWidth * 0.06)),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!ready || Service.settingsService.pref_getScryfallImages)
                            const LinearProgressIndicator()
                          else
                            const SizedBox(height: 3.5),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ready && cardSets.isNotEmpty && !Service.settingsService.pref_getScryfallImages
                                  ? CardTextPreview(
                                      card: cardSets.first,
                                      showSet: widget.card is! SearchableCard,
                                    )
                                  : Text(
                                      widget.card == null
                                          ? "Error fetching card"
                                          : (widget.card is CardSet || widget.card is SearchableCard)
                                              ? widget.card?.name
                                              : cardSets.isNotEmpty
                                                  ? cardSets.first.name
                                                  : '',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      if (ready)
                        if (Service.settingsService.pref_getScryfallImages)
                          Image.network(
                            imageUrlLarge,
                            fit: BoxFit.contain,
                            cacheHeight: 936,
                            cacheWidth: 672,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints bc) {
                                var size = min(bc.maxHeight, bc.maxWidth) * 0.4;
                                return Center(
                                  child: Opacity(
                                    opacity: 0.3,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: size,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void setup() async {
    if (widget.card != null && widget.card is String) {
      var c = await Service.dataLoader.cardByUUID(widget.card);
      if (c == null) {
        setState(() {
          valid = false;
        });
        return;
      }
      cardSets.add(c);
      isSingle = true;
      ready = true;
    } else if (widget.card != null && widget.card is CardSet) {
      cardSets.add(widget.card);
      isSingle = true;
      ready = true;
    } else if (widget.card != null && widget.card is SearchableCard) {
      SearchableCard c = widget.card;
      cardSets = await Service.dataLoader.cardsByName(c.name);
      if (cardSets.isNotEmpty) ready = true;
    } else {
      setState(() {
        valid = false;
      });
      return;
    }
    if (ready) {
      String? id = cardSets.first.identifiers.scryfallId;
      if (id == null) {
        ready = false;
        valid = false;
        return;
      }
      String fileFace = 'front';
      String dir1 = id[0];
      String dir2 = id[1];
      imageUrl = 'https://cards.scryfall.io/normal/$fileFace/$dir1/$dir2/$id.jpg';
      imageUrlLarge = 'https://cards.scryfall.io/large/$fileFace/$dir1/$dir2/$id.jpg';
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      child: AspectRatio(
        aspectRatio: 488 / 680,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 2.0,
                style: BorderStyle.solid,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.all(Radius.circular(constraints.maxWidth * 0.06)),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!ready || Service.settingsService.pref_getScryfallImages)
                      const LinearProgressIndicator()
                    else
                      const SizedBox(height: 3.5),
                    ready && cardSets.isNotEmpty && !Service.settingsService.pref_getScryfallImages
                        ? widget.fadeText
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.black, Color.fromARGB(50, 0, 0, 0), Colors.transparent],
                                      ).createShader(Rect.fromLTRB(0, rect.height - 50, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: CardTextPreview(
                                        card: cardSets.first,
                                        showSet: widget.card is! SearchableCard,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: CardTextPreview(
                                  card: cardSets.first,
                                  showSet: widget.card is! SearchableCard,
                                ),
                              )
                        : SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                widget.card == null
                                    ? "Error fetching card"
                                    : (widget.card is CardSet || widget.card is SearchableCard)
                                        ? widget.card?.name
                                        : cardSets.isNotEmpty
                                            ? cardSets.first.name
                                            : '',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ],
                ),
                if (ready)
                  if (Service.settingsService.pref_getScryfallImages)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      cacheHeight: 680,
                      cacheWidth: 488,
                      errorBuilder: (context, error, stackTrace) => LayoutBuilder(builder: (BuildContext context, BoxConstraints bc) {
                        var size = min(bc.maxHeight, bc.maxWidth) * 0.4;
                        return Center(
                          child: Opacity(
                            opacity: 0.3,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: size,
                            ),
                          ),
                        );
                      }),
                    ),
                if (ready && widget.dialogPreview)
                  Opacity(
                    opacity: 0.2,
                    child: FilledButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(0, 255, 255, 255),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        showDialogPreview();
                      },
                      child: Container(),
                    ),
                  ),
                if (ready && !isSingle && !widget.hideButtons && widget.qty == null)
                  Opacity(
                    opacity: 0.2,
                    child: FilledButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(0, 255, 255, 255),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        var result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CardPage(
                              card: cardSets.first.name,
                              selectCard: widget.selectCard,
                              deckCards: widget.deckCards,
                            ),
                          ),
                        );
                        if (widget.selectCard && mounted && result != null && result is String) {
                          Navigator.of(context).pop(result);
                        }
                      },
                      child: Container(),
                    ),
                  ),
                if (ready && isSingle && !widget.hideButtons && widget.qty != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: 0.9,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) => Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(64)),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 38.0,
                                      child: FilledButton(
                                        style: const ButtonStyle(
                                          padding: MaterialStatePropertyAll(
                                            EdgeInsets.symmetric(vertical: 12.0),
                                          ),
                                          shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (widget.qtyChanged != null) widget.qtyChanged!((widget.qty ?? 1) - 1);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 4.0),
                                          child: Icon(
                                            (widget.qty ?? 1) > 1 ? Icons.remove : Icons.delete,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(64)),
                                        color: Theme.of(context).colorScheme.background,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 18.0),
                                        child: Container(
                                          constraints: const BoxConstraints(minWidth: 14.0),
                                          child: Text(
                                            widget.qty.toString(),
                                            style: const TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 38.0,
                                      child: FilledButton(
                                        style: const ButtonStyle(
                                          padding: MaterialStatePropertyAll(
                                            EdgeInsets.symmetric(vertical: 12.0),
                                          ),
                                          shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (widget.qtyChanged != null) widget.qtyChanged!((widget.qty ?? 1) + 1);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 4.0),
                                          child: Icon(
                                            Icons.add,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.isCommander)
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: 0.5,
                        child: Icon(
                          KeyruneIcons.ss_cmd,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 2.0,
                              color: Color.fromARGB(100, 0, 0, 0),
                            ),
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 1.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
