import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:andax/modules/editor/widgets/node_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../utils/pickers.dart';

Future<Transition?> showTransitionEditor(
  BuildContext context,
  Node node, [
  Transition? value,
]) async {
  final editor = context.read<StoryEditorState>();
  final Transition result;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    final targetNode = await pickNode(context);
    if (targetNode == null) return value;
    if (node.transitionInputSource == TransitionInputSource.cell) {
      final targetCell = await pickCell(context);
      if (targetCell == null) return value;
      result = CelledTransition(
        id,
        targetNodeId: targetNode.id,
        targetCellId: targetCell.id,
      );
    } else {
      result = Transition(
        id,
        targetNodeId: targetNode.id,
      );
    }
    translation = MessageTranslation(
      id,
      text: 'Transition #${node.transitions.length + 1}',
    );
  } else {
    if (node.transitionInputSource == TransitionInputSource.cell) {
      result = CelledTransition.fromJson(value.toJson());
    } else {
      result = Transition.fromJson(value.toJson());
    }
    translation = MessageTranslation.get(editor.translation, result.id)!;
  }

  String newText = translation.text ?? '';
  return showEditorSheet<Transition>(
    context: context,
    title: value == null ? 'Create transition' : 'Edit transition',
    initial: value,
    onSave: () {
      translation.text = newText;
      if (value == null) {
        node.transitions.add(result);
      } else {
        node.transitions[node.transitions.indexOf(value)] = result;
      }
      editor.translation[result.id] = translation;
      return result;
    },
    onDelete: value == null
        ? null
        : () {
            node.transitions.remove(value);
            editor.translation.assets.remove(value.id);
          },
    builder: (_, setState) {
      return [
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Transition text',
              prefixIcon: Icon(Icons.short_text_rounded),
            ),
            autofocus: true,
            initialValue: translation.text,
            validator: emptyValidator,
            onChanged: (s) {
              newText = s.trim();
            },
          ),
        ),
        buildExplanationTile(context, 'Target node'),
        Provider.value(
          value: editor,
          child: NodeTile(
            editor.story.nodes[result.targetNodeId],
            onTap: () => pickNode(
              context,
              editor.story.nodes[result.targetNodeId],
            ).then((r) {
              if (r != null) {
                setState(() {
                  result.targetNodeId = r.id;
                });
              }
            }),
          ),
        ),
        if (node.transitionInputSource == TransitionInputSource.cell)
          Builder(
            builder: (context) {
              final celled = result as CelledTransition;
              void setMode(ComparisionMode? v) => setState(() {
                    celled.comparision = v;
                  });
              return Column(
                children: [
                  buildExplanationTile(context, 'Cell-controlled logic'),
                  Provider.value(
                    value: editor,
                    child: CellTile(
                      editor.story.cells[celled.targetCellId],
                      onTap: () => pickCell(context).then(
                        (v) => setState(() {
                          celled.targetCellId = v?.id ?? celled.targetCellId;
                        }),
                      ),
                    ),
                  ),
                  RadioListTile<ComparisionMode?>(
                    value: null,
                    groupValue: celled.comparision,
                    title: const Text('OK'),
                    subtitle: const Text('Always passes (use for default)'),
                    onChanged: setMode,
                  ),
                  RadioListTile<ComparisionMode?>(
                    value: ComparisionMode.equal,
                    groupValue: celled.comparision,
                    title: const Text('[=] Equal'),
                    subtitle: const Text('Are the values exactly the same?'),
                    onChanged: setMode,
                  ),
                  RadioListTile<ComparisionMode?>(
                    value: ComparisionMode.lesser,
                    groupValue: celled.comparision,
                    title: const Text('[<] Lesser'),
                    subtitle: const Text('Is the number in the cell smaller?'),
                    onChanged: setMode,
                  ),
                  RadioListTile<ComparisionMode?>(
                    value: ComparisionMode.greater,
                    groupValue: celled.comparision,
                    title: const Text('[>] Greater'),
                    subtitle: const Text('Is the number in the cell greater?'),
                    onChanged: setMode,
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Comparision value',
                        prefixIcon: Icon(Icons.turned_in_rounded),
                      ),
                      autofocus: true,
                      initialValue: celled.value,
                      validator: emptyValidator,
                      onChanged: (s) {
                        celled.value = s.trim();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ];
    },
  );
}
