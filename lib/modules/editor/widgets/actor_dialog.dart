import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../utils/editor_sheet.dart';

Future<Actor?> showActorEditorDialog(
  BuildContext context, [
  Actor? value,
]) {
  final editor = context.read<StoryEditorState>();
  final Actor result;
  final ActorTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    result = Actor(id);
    translation = ActorTranslation(
      id,
      name: 'Actor #${editor.story.actors.length + 1}',
    );
  } else {
    result = Actor.fromJson(value.toJson());
    translation = ActorTranslation.get(editor.translation, result.id)!;
  }

  String newName = translation.name;
  return showEditorSheet<Actor>(
    context: context,
    title: value == null ? 'Create actor' : 'Edit actor',
    initial: value,
    onSave: () {
      translation.name = newName;
      editor.story.actors[result.id] = result;
      editor.translation[result.id] = translation;
      return result;
    },
    onDelete: value == null
        ? null
        : () {
            editor.story.actors.remove(value.id);
            editor.translation.assets.remove(value.id);
          },
    builder: (context, setState) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Actor name',
            ),
            autofocus: true,
            initialValue: translation.name,
            validator: emptyValidator,
            onChanged: (s) {
              newName = s.trim();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Actor mode',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ListTile(
          selected: result.type == ActorType.npc,
          onTap: () => setState(() {
            result.type = ActorType.npc;
          }),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          horizontalTitleGap: 12,
          leading: const Icon(Icons.smart_toy_rounded),
          title: const Text('Computer actor'),
          subtitle: const Text('Follows the narrative'),
        ),
        ListTile(
          selected: result.type == ActorType.player,
          onTap: () => setState(() {
            result.type = ActorType.player;
          }),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          horizontalTitleGap: 12,
          leading: const Icon(Icons.face_rounded),
          title: const Text('Player actor'),
          subtitle: const Text('Controlled by the player'),
        ),
      ];
    },
  );
}
