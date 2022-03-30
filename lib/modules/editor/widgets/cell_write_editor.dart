import 'package:andax/models/cell_write.dart';
import 'package:andax/models/node.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../utils/pickers.dart';

Future<CellWrite?> showCellWrite(
  BuildContext context,
  Node node, [
  CellWrite? value,
]) async {
  final editor = context.read<StoryEditorState>();
  CellWrite write;

  if (value == null) {
    final target = await pickCell(context);
    if (target == null) return value;
    write = CellWrite(target.id);
  } else {
    write = CellWrite.fromJson(value.toJson());
  }

  return showEditorSheet<CellWrite>(
    context: context,
    title: value == null ? 'Create cell write' : 'Edit cell write',
    initial: value,
    onSave: () {
      if (value == null) {
        node.cellWrites.add(write);
      } else {
        node.cellWrites[node.cellWrites.indexOf(value)] = write;
      }
      return write;
    },
    onDelete: value == null ? null : () => node.cellWrites.remove(value),
    builder: (_, setState) {
      void setMode(CellWriteMode? v) =>
          setState(() => write.mode = v ?? write.mode);
      return [
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Write value',
              prefixIcon: Icon(Icons.edit_rounded),
            ),
            autofocus: true,
            initialValue: write.value,
            validator: emptyValidator,
            onChanged: (s) => write.value = s.trim(),
          ),
        ),
        buildExplanationTile(context, 'Target cell'),
        Provider.value(
          value: editor,
          child: CellTile(
            editor.story.cells[write.targetCellId],
            onTap: () => pickCell(
              context,
              editor.story.cells[write.targetCellId],
            ).then((r) {
              if (r != null) {
                setState(() => write.targetCellId = r.id);
              }
            }),
          ),
        ),
        buildExplanationTile(
          context,
          'Write mode',
          'Controls how the new value is set',
        ),
        RadioListTile<CellWriteMode>(
          value: CellWriteMode.overwrite,
          groupValue: write.mode,
          title: const Text('Overwrite'),
          subtitle: const Text('Completely replaces old value'),
          secondary: const Icon(Icons.save_alt_rounded),
          onChanged: setMode,
        ),
        RadioListTile<CellWriteMode>(
          value: CellWriteMode.add,
          groupValue: write.mode,
          title: const Text('Add'),
          subtitle: const Text('Numerically adds to old value or 0'),
          secondary: const Icon(Icons.add_circle_outline_rounded),
          onChanged: setMode,
        ),
        RadioListTile<CellWriteMode>(
          value: CellWriteMode.subtract,
          groupValue: write.mode,
          title: const Text('Subtract'),
          subtitle: const Text('Numerically subtracts from old value or 0'),
          secondary: const Icon(Icons.remove_circle_outline_rounded),
          onChanged: setMode,
        ),
      ];
    },
  );
}
