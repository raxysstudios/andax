import 'package:andax/models/cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final keep = await showEditorSheet(
    context: context,
    title: value == null ? 'Create cell' : 'Edit cell',
    onDelete: value == null
        ? null
        : () {
            editor.story.cells.remove(value.id);
            editor.translation.assets.remove(value.id);
          },
    builder: (context, setState) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cell max numeric value',
              prefixIcon: Icon(Icons.score_rounded),
            ),
            autofocus: true,
            initialValue: cell.max?.toString(),
            onChanged: (s) {
              cell.max = int.tryParse(s.trim());
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Display mode',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ToggleButtons(
            children: const [
              Tooltip(
                message: 'Hidden',
                child: Icon(Icons.visibility_off_rounded),
              ),
              Tooltip(
                message: 'Check (true/false)',
                child: Icon(Icons.check_circle_rounded),
              ),
              Tooltip(
                message: 'Text (as is)',
                child: Icon(Icons.short_text_rounded),
              ),
              Tooltip(
                message: 'Range (with max)',
                child: Icon(Icons.linear_scale_rounded),
              ),
            ],
            onPressed: (int i) => setState(() {
              cell.display = i == 0 ? null : CellDisplay.values[i - 1];
            }),
            isSelected: [
              cell.display == null,
              ...CellDisplay.values.map((e) => e == cell.display),
            ],
            renderBorder: false,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ];
    },
  );
  
  if (keep == null) return value;
  if (keep) {
    translation.text = newName;
    editor.story.cells[cell.id] = cell;
    editor.translation[cell.id] = translation;
  }
  return null;
}
