import 'package:andax/models/cell.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/shared/extensions.dart';
import 'package:flutter/material.dart';

class CellsList extends StatelessWidget {
  const CellsList({
    required this.cells,
    required this.translation,
    Key? key,
  }) : super(key: key);

  final List<Cell> cells;
  final Translation translation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final cell in cells.where((c) => c.display != null))
          ListTile(
            dense: true,
            title: Text(
              MessageTranslation.getText(
                translation,
                cell.id,
              ).titleCase,
            ),
            trailing: Builder(
              builder: (context) {
                final text = cell.value;
                switch (cell.display) {
                  case CellDisplay.check:
                    return Icon(
                      text.isEmpty
                          ? Icons.radio_button_unchecked_rounded
                          : Icons.check_circle_outline_rounded,
                    );
                  case CellDisplay.range:
                    return Text('$text/${cell.max}');
                  default:
                    return Text(text);
                }
              },
            ),
          ),
      ],
    );
  }
}
