import 'package:andax/models/cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/snackbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

String _cellsToText(PlayScreenState play) {
  final translation = play.widget.translation;
  var text = (StoryTranslation.get(translation)?.title ?? '') + '\n';

  for (final cell in play.cells.values) {
    text += '\n' + MessageTranslation.getText(translation, cell.id) + ': ';
    switch (cell.display) {
      case CellDisplay.check:
        text += cell.value.isEmpty ? '✔️' : '❌';
        break;
      case CellDisplay.range:
        text += cell.value;
        if (cell.max != null) text += ' / ' + cell.max.toString();
        break;
      default:
        text += cell.value;
    }
  }
  return text;
}

Future<void> showGameResultsDialog(
  BuildContext context,
  PlayScreenState play,
) async {
  final copied = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Provider.value(
        value: play,
        child: AlertDialog(
          title: const Text('Your results'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (final cell
                    in play.cells.values.where((c) => c.display != null)) ...[
                  ListTile(
                    dense: true,
                    title: Text(
                      MessageTranslation.getText(
                        play.widget.translation,
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
                  const Divider(indent: 8, endIndent: 8),
                ]
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.inventory_rounded),
              label: const Text('To Clipboard'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded),
              label: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
  if (copied ?? false) {
    await Clipboard.setData(
      ClipboardData(text: _cellsToText(play)),
    );
    showSnackbar(
      context,
      Icons.content_copy_rounded,
      'Copied!',
      false,
    );
  }
}
