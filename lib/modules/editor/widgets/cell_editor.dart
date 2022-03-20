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
            initialValue: result.max?.toString(),
            onChanged: (s) {
              result.max = int.tryParse(s.trim());
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
        buildTitle(context, 'Display mode'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              result.display = i == 0 ? null : CellDisplay.values[i - 1];
            }),
            isSelected: [
              result.display == null,
              ...CellDisplay.values.map((e) => e == result.display),
            ],
            renderBorder: false,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ];
    },
  );
}
