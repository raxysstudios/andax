import 'package:andax/models/cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

Future<Cell?> showCellEditorDialog(
  BuildContext context, [
  Cell? value,
]) async {
  final editor = context.read<StoryEditorState>();
  final Cell cell;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    cell = Cell(id);
    translation = MessageTranslation(
      id,
      text: 'Cell #${editor.story.cells.length + 1}',
    );
  } else {
    cell = Cell.fromJson(value.toJson());
    translation = MessageTranslation.get(editor.translation, cell.id)!;
  }

  String? newName = translation.text;
  final result = await showEditorDialog<Cell>(
    context,
    result: () => cell,
    title: value == null ? 'Create cell' : 'Edit cell',
    initial: value,
    padding: EdgeInsets.zero,
    builder: (context, setState) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell name',
            ),
            autofocus: true,
            initialValue: translation.text,
            validator: emptyValidator,
            onChanged: (s) {
              newName = s.trim();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Cell max numeric value',
              prefixIcon: Icon(cell.numeric
                  ? Icons.calculate_rounded
                  : Icons.text_fields_rounded),
            ),
            autofocus: true,
            initialValue: cell.max?.toString(),
            validator: emptyValidator,
            onChanged: (s) {
              cell.max = int.tryParse(s.trim());
            },
          ),
        ),
      ];
    },
  );
  if (result == null) {
    if (value != null) {
      editor.story.cells.remove(value.id);
      editor.translation.assets.remove(value.id);
    }
  } else if (result != value) {
    translation.text = newName;
    editor.story.cells[result.id] = result;
    editor.translation[result.id] = translation;
  }
  return result;
}
