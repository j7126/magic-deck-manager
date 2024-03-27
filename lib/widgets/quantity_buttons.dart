import 'package:flutter/material.dart';

class QuantityButtons extends StatefulWidget {
  const QuantityButtons({
    super.key,
    this.qty,
    this.qtyChanged,
  });

  final int? qty;
  final Function(int)? qtyChanged;

  @override
  State<QuantityButtons> createState() => _QuantityButtonsState();
}

class _QuantityButtonsState extends State<QuantityButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
