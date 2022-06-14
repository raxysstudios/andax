import 'package:andax/models/cell.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/snackbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GameResults extends StatelessWidget {
  const GameResults({Key? key}) : super(key: key);

  String _cellsToText(PlayScreenState play) {
    var text = '${play.tr.title}\n';
    final cells = play.cells.values.where((c) => c.display != null);
    for (final cell in cells) {
      text += '\n${play.tr.cell(cell).titleCase}: ';
      switch (cell.display) {
        case CellDisplay.check:
          text += cell.value.isEmpty ? '✔️' : '❌';
          break;
        case CellDisplay.range:
          text += cell.value;
          if (cell.max != double.infinity) text += ' / ${cell.max}';
          break;
        default:
          text += cell.value;
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    final cells = play.cells.values.where((c) => c.display != null);
    if (cells.isEmpty) return const SizedBox();
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Results',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: _cellsToText(play)),
              );
              // I guess using context here is fine since clipboard writing should be fast enough
              // ignore: use_build_context_synchronously
              showSnackbar(
                context,
                Icons.content_copy_rounded,
                'Saved to clipboard!',
                false,
              );
            },
            label: const Text('Copy'),
            icon: const Icon(Icons.inventory_rounded),
          ),
        ),
        const Divider(),
        for (final cell in cells)
          ListTile(
            dense: true,
            title: Text(play.tr.cell(cell).titleCase),
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
                    return Text('$text / ${cell.max}');
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
