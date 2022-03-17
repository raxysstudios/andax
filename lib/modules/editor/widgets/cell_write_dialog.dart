import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../services/pickers.dart';

Future<MapEntry<String, String>?> showCellWriteDialog(
  BuildContext context,
  Node node, [
  MapEntry<String, String>? value,
]) async {
  final editor = context.read<StoryEditorState>();
  Cell cell;
  String write;

  if (editor.story.cells[value?.key] == null) {
    node.cellWrites?.remove(value?.key);
    value = null;
  }
  if (value == null) {
    final c = await pickCell(context);
    if (c == null) return value;
    cell = c;
    write = '';
  } else {
    cell = editor.story.cells[value.key]!;
    write = node.cellWrites?[cell.id] ?? '';
  }

  final result = await showEditorDialog<MapEntry<String, String>>(
    context,
    result: () => MapEntry(cell.id, write),
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
              onTap: () => pickCell(context, cell).then((r) {
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
              labelText: 'Write value',
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
      node.cellWrites?.remove(value.key);
    }
  } else {
    node.cellWrites ??= {};
    node.cellWrites!.update(
      result.key,
      (_) => result.value,
      ifAbsent: () => result.value,
    );
  }
  return result;
}
