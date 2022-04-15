import 'package:andax/models/cell.dart';
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
  final Cell cell;
  String name;

  if (value == null) {
    final id = editor.uuid.v4();
    cell = Cell(id);
    name = 'Cell #${editor.story.cells.length + 1}';
  } else {
    cell = Cell.fromJson(value.toJson());
    name = editor.tr.cell(cell);
  }

  return showEditorSheet<Cell>(
    context: context,
    title: value == null ? 'Create cell' : 'Edit cell',
    initial: value,
    onSave: () {
      editor.story.cells[cell.id] = cell;
      editor.tr[cell.id] = name;
      return cell;
    },
    onDelete: value == null
        ? null
        : () {
            editor.story.cells.remove(value.id);
            editor.tr.assets.remove(value.id);
          },
    builder: (context, setState) {
      void setDisplay(CellDisplay? v) => setState(() => cell.display = v);
      return [
        ListTile(
          leading: const Icon(Icons.label_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell name',
            ),
            autofocus: true,
            initialValue: name,
            validator: emptyValidator,
            onChanged: (s) => name = s.trim(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.score_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell max numeric value',
            ),
            autofocus: true,
            initialValue:
                cell.max == double.infinity ? '' : cell.max.toString(),
            onChanged: (s) =>
                cell.max = num.tryParse(s.trim()) ?? double.infinity,
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
          groupValue: cell.display,
          title: const Text('Hidden'),
          subtitle: const Text('Internal logic, not shown to player'),
          secondary: const Icon(Icons.visibility_off_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.check,
          groupValue: cell.display,
          title: const Text('Check'),
          subtitle: const Text('Displays objectives, marks events'),
          secondary: const Icon(Icons.check_circle_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.range,
          groupValue: cell.display,
          title: const Text('Range'),
          subtitle: const Text('For numeric scores, better with max value'),
          secondary: const Icon(Icons.short_text_rounded),
          onChanged: setDisplay,
        ),
        RadioListTile<CellDisplay>(
          value: CellDisplay.text,
          groupValue: cell.display,
          title: const Text('Text'),
          subtitle: const Text('Plain text, for general use'),
          secondary: const Icon(Icons.linear_scale_rounded),
          onChanged: setDisplay,
        ),
      ];
    },
  );
}
