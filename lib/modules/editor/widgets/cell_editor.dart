import 'package:andax/models/cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

Future<Cell?> showCellEditor(
  BuildContext context, [
  Cell? value,
]) {
  final editor = context.read<StoryEditorState>();
  final Cell result;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    result = Cell(id);
    translation = MessageTranslation(
      id,
      text: 'Cell #${editor.story.cells.length + 1}',
    );
  } else {
    result = Cell.fromJson(value.toJson());
    translation = MessageTranslation.get(editor.translation, result.id)!;
  }

  String? newName = translation.text;
  return showEditorSheet<Cell>(
    context: context,
    title: value == null ? 'Create cell' : 'Edit cell',
    initial: value,
    onSave: () {
      translation.text = newName;
      editor.story.cells[result.id] = result;
      editor.translation[result.id] = translation;
      return result;
    },
    onDelete: value == null
        ? null
        : () {
            editor.story.cells.remove(value.id);
            editor.translation.assets.remove(value.id);
          },
    builder: (context, setState) {
      void setDisplay(CellDisplay? v) => setState(() {
            result.display = v;
          });
      return [
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell name',
              prefixIcon: Icon(Icons.label_rounded),
            ),
            autofocus: true,
            initialValue: translation.text,
            validator: emptyValidator,
            onChanged: (s) {
              newName = s.trim();
            },
          ),
        ),
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell max numeric value',
              prefixIcon: Icon(Icons.score_rounded),
            ),
            autofocus: true,
            initialValue: result.max.toString(),
            onChanged: (s) =>
                result.max = int.tryParse(s.trim()) ?? double.infinity,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        buildExplanationTile(
          context,
          'Display mode',
          'Controls the presentation on post-game scoreboard',
        ),
        RadioListTile<CellDisplay?>(
          value: null,
          groupValue: result.display,
          title: const Text('Hidden'),
          subtitle: const Text('Internal logic, not shown to player'),
          secondary: const Icon(Icons.visibility_off_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.check,
          groupValue: result.display,
          title: const Text('Check'),
          subtitle: const Text('Displays objectives, marks events'),
          secondary: const Icon(Icons.check_circle_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.range,
          groupValue: result.display,
          title: const Text('Range'),
          subtitle: const Text('For numeric scores, better with max value'),
          secondary: const Icon(Icons.short_text_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.text,
          groupValue: result.display,
          title: const Text('Text'),
          subtitle: const Text('Plain text, for general use'),
          secondary: const Icon(Icons.linear_scale_rounded),
          onChanged: setDisplay,
        ),
      ];
    },
  );
}
