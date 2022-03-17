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
              Icon(Icons.visibility_off_rounded),
              Icon(Icons.check_circle_rounded),
              Icon(Icons.short_text_rounded),
              Icon(Icons.linear_scale_rounded),
            ],
            onPressed: (int index) {
              setState(() {
                cell.display = CellDisplay.values[index];
              });
            },
            isSelected:
                CellDisplay.values.map((e) => e == cell.display).toList(),
            renderBorder: false,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // for (final display in CellDisplay.values)
        //   RadioListTile<CellDisplay>(
        //     title: Text(display.name),
        //     value: display,
        //     groupValue: cell.display,
        //     onChanged: (value) {
        //       if (value != null) {
        //         setState(() {
        //           cell.display = value;
        //         });
        //       }
        //     },
        //   ),
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
