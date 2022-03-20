import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/modules/editor/widgets/node_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../utils/pickers.dart';

Future<Transition?> showTransitionEditorDialog(
  BuildContext context,
  Node node, [
  Transition? value,
]) async {
  final editor = context.read<StoryEditorState>();
  final Transition result;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    final target = await pickNode(context);
    if (target == null) return value;
    result = Transition(
      id,
      targetNodeId: target.id,
    );
    translation = MessageTranslation(
      id,
      text: 'Transition #${node.transitions.length + 1}',
    );
  } else {
    result = Transition.fromJson(value.toJson());
    translation = MessageTranslation.get(editor.translation, result.id)!;
  }

  String newText = translation.text ?? '';
  return showEditorSheet<Transition>(
    context: context,
    title: value == null ? 'Create actor' : 'Edit actor',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Transition text',
            ),
            autofocus: true,
            initialValue: translation.text,
            validator: emptyValidator,
            onChanged: (s) {
              newText = s.trim();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Target node',
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
              final node = editor.story.nodes[result.targetNodeId]!;
              return NodeTile(
                node,
                onTap: () => pickNode(context, node).then((r) {
                  if (r != null) {
                    setState(() {
                      result.targetNodeId = r.id;
                    });
                  }
                }),
              );
            }),
          ),
        ),
      ];
    },
  );
}
