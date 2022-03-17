import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/widgets/node_tile.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../services/pickers.dart';

Future<Transition?> showTransitionEditorDialog(
  BuildContext context,
  Node node, [
  Transition? value,
]) async {
  final editor = context.read<StoryEditorState>();
  final Transition transition;
  final MessageTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    final target = await pickNode(context);
    if (target == null) return value;
    transition = Transition(
      id,
      targetNodeId: target.id,
    );
    translation = MessageTranslation(
      id,
      text: 'Transition #${editor.story.actors.length + 1}',
    );
  } else {
    transition = Transition.fromJson(value.toJson());
    translation = MessageTranslation.get(editor.translation, transition.id)!;
  }

  String newText = translation.text ?? '';
  final result = await showEditorDialog<Transition>(
    context,
    result: () => transition,
    title: value == null ? 'Create actor' : 'Edit actor',
    initial: value,
    padding: EdgeInsets.zero,
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
            child: NodeTile(
              editor.story.nodes[transition.targetNodeId]!,
              onTap: () => pickNode(context).then((r) {
                if (r != null) {
                  setState(() {
                    transition.targetNodeId = r.id;
                  });
                }
              }),
            ),
          ),
        ),
      ];
    },
  );
  if (result == null) {
    if (value != null) {
      node.transitions?.remove(value);
      editor.translation.assets.remove(value.id);
    }
  } else if (result != value) {
    translation.text = newText;
    node.transitions ??= [];
    if (value == null) {
      node.transitions!.add(result);
    } else {
      node.transitions![node.transitions!.indexOf(value)] = result;
    }
    editor.translation[result.id] = translation;
  }
  return result;
}
