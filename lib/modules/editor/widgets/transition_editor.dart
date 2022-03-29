import 'package:andax/models/cell_check.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
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
  final Transition transition;
  String? label;

  if (value == null) {
    final id = editor.uuid.v4();
    final targetNode = await pickNode(context);
    if (targetNode == null) return value;
    transition = Transition(
      id,
      targetNodeId: targetNode.id,
      condition: node.input == NodeInputType.select
          ? CellCheck(cellId: '')
          : CellCheck(
              cellId: 'node',
              operator: CheckOperator.equal,
              value: node.transitions.length.toString(),
            ),
    );
    label = 'Transition #${node.transitions.length + 1}';
  } else {
    transition = Transition.fromJson(value.toJson());
    label = node.input == NodeInputType.select
        ? editor.tr.transition(transition)
        : null;
  }
  return showEditorSheet<Transition>(
    context: context,
    title: value == null ? 'Create transition' : 'Edit transition',
    initial: value,
    onSave: () {
      if (value == null) {
        node.transitions.add(transition);
      } else {
        node.transitions[node.transitions.indexOf(value)] = transition;
      }
      if (label != null) {
        editor.tr[transition.id] = label!;
      }
      return transition;
    },
    onDelete: value == null
        ? null
        : () {
            node.transitions.remove(value);
            editor.tr.assets.remove(value.id);
          },
    builder: (_, setState) {
      return [
        if (label != null)
          ListTile(
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Transition text',
                prefixIcon: Icon(Icons.short_text_rounded),
              ),
              autofocus: true,
              initialValue: label,
              validator: emptyValidator,
              onChanged: (s) => label = s.trim(),
            ),
          ),
        buildExplanationTile(context, 'Target node'),
        Provider.value(
          value: editor,
          child: NodeTile(
            editor.story.nodes[transition.targetNodeId],
            onTap: () => pickNode(
              context,
              editor.story.nodes[transition.targetNodeId],
            ).then((r) {
              if (r != null) {
                setState(() => transition.targetNodeId = r.id);
              }
            }),
          ),
        ),
        if (node.input == NodeInputType.none)
          Provider.value(
            value: editor,
            builder: (context, _) {
              final condition = transition.condition;
              void setOperator(CheckOperator? v) => setState(
                    () => condition.operator = v ?? condition.operator,
                  );
              return Column(
                children: [
                  buildExplanationTile(context, 'Cell-based condition'),
                  CellTile(
                    editor.story.cells[condition.cellId],
                    onTap: () => pickCell(context).then(
                      (v) => setState(
                        () => condition.cellId = v?.id ?? condition.cellId,
                      ),
                    ),
                  ),
                  RadioListTile<CheckOperator>(
                    value: CheckOperator.pass,
                    groupValue: condition.operator,
                    title: const Text('Pass'),
                    subtitle: const Text('Always true (use for default)'),
                    onChanged: setOperator,
                  ),
                  RadioListTile<CheckOperator?>(
                    value: CheckOperator.equal,
                    groupValue: condition.operator,
                    title: const Text('[=] Equal'),
                    subtitle: const Text('Are the values exactly the same?'),
                    onChanged: setOperator,
                  ),
                  RadioListTile<CheckOperator?>(
                    value: CheckOperator.less,
                    groupValue: condition.operator,
                    title: const Text('[<] Less'),
                    subtitle: const Text('Is the number in the cell smaller?'),
                    onChanged: setOperator,
                  ),
                  RadioListTile<CheckOperator?>(
                    value: CheckOperator.greater,
                    groupValue: condition.operator,
                    title: const Text('[>] Greater'),
                    subtitle: const Text('Is the number in the cell greater?'),
                    onChanged: setOperator,
                  ),
                  if (condition.operator != CheckOperator.pass)
                    ListTile(
                      title: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Comparison value',
                          prefixIcon: Icon(Icons.turned_in_rounded),
                        ),
                        autofocus: true,
                        initialValue: condition.value,
                        onChanged: (s) => condition.value = s.trim(),
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
