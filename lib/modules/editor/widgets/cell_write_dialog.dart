import 'package:andax/models/cell_write.dart';
import 'package:andax/models/node.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../services/pickers.dart';

Future<CellWrite?> showCellWriteDialog(
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

  final result = await showEditorDialog<CellWrite>(
    context,
    result: () => write,
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
            child: Builder(builder: (context) {
              final cell = editor.story.cells[write.targetCellId];
              return CellTile(
                cell,
                onTap: () => pickCell(context, cell).then((r) {
                  if (r != null) {
                    setState(() {
                      write.targetCellId = r.id;
                    });
                  }
                }),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Write mode',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ToggleButtons(
            children: const [
              Tooltip(
                message: 'Overwrite',
                child: Icon(Icons.drive_file_rename_outline_rounded),
              ),
              Tooltip(
                message: 'Add (fallback to 0)',
                child: Icon(Icons.add_circle_outline_rounded),
              ),
              Tooltip(
                message: 'Subtract (fallback to 0)',
                child: Icon(Icons.remove_circle_outline_rounded),
              ),
            ],
            onPressed: (int i) => setState(() {
              write.mode = CellWriteMode.values[i];
            }),
            isSelected:
                CellWriteMode.values.map((e) => e == write.mode).toList(),
            renderBorder: false,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Write value',
            ),
            autofocus: true,
            initialValue: write.value,
            validator: emptyValidator,
            onChanged: (s) {
              write.value = s.trim();
            },
          ),
        ),
      ];
    },
  );
  if (result == null) {
    if (value != null) {
      node.cellWrites.remove(value);
    }
  } else if (value == null) {
    node.cellWrites.add(result);
  } else {
    node.cellWrites[node.cellWrites.indexOf(value)] = result;
  }
  return result;
}
