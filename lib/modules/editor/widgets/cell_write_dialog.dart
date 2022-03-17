import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:andax/modules/editor/widgets/node_tile.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../services/pickers.dart';

Future<Cell?> showTransitionEditorDialog(
  BuildContext context,
  Node node, [
  Cell? value,
]) async {
  final editor = context.read<StoryEditorState>();
  Cell cell;

  if (value == null) {
    final c = await pickCell(context);
    if (c == null) return value;
    cell = c;
  } else {
    cell = value;
  }

  var write = '';
  final result = await showEditorDialog<Cell>(
    context,
    result: () => cell,
    title: value == null ? 'Create cell write' : 'Edit cell write',
    initial: value,
    padding: EdgeInsets.zero,
    builder: (_, setState) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Target cell',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Provider.value(
          value: editor,
          child: ListTileTheme(
            data: Theme.of(context).listTileTheme.copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                ),
            child: CellTile(
              cell,
              onTap: () => pickCell(context).then((r) {
                if (r != null) {
                  setState(() {
                    cell = r;
                  });
                }
              }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Transition text',
            ),
            autofocus: true,
            initialValue: write,
            validator: emptyValidator,
            onChanged: (s) {
              write = s.trim();
            },
          ),
        ),
      ];
    },
  );
  if (result == null) {
    if (value != null) {
      node.cellWrites?.remove(value.id);
    }
  } else {
    node.cellWrites?.update(
      result.id,
      (_) => write,
      ifAbsent: () => write,
    );
  }
  return result;
}
