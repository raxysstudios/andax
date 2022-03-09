import 'package:andax/models/storage_cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

Future<StorageCell?> showStorageCellEditorDialog(
  BuildContext context, [
  StorageCell? value,
]) async {
  final editor = context.read<StoryEditorState>();
  final StorageCell cell;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    cell = StorageCell(id);
    translation = MessageTranslation(
      id: id,
      text: 'Cell #${editor.story.storage.length + 1}',
    );
  } else {
    cell = StorageCell.fromJson(value.toJson());
    translation = MessageTranslation.get(editor.translation, cell.id)!;
  }

  String? newName = translation.text;
  final result = await showEditorDialog<StorageCell>(
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
      editor.story.storage.remove(value.id);
      editor.translation.assets.remove(value.id);
    }
  } else if (result != value) {
    translation.text = newName;
    editor.story.storage[result.id] = result;
    editor.translation[result.id] = translation;
  }
  return result;
}
