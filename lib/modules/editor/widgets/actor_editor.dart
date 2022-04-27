import 'package:andax/models/actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/editor_sheet.dart';
import '../screens/story.dart';

Future<Actor?> showActorEditor(
  BuildContext context, [
  Actor? value,
]) {
  final editor = context.read<StoryEditorState>();
  final Actor actor;
  String name;

  if (value == null) {
    final id = editor.uuid.v4();
    actor = Actor(id);
    name = 'Character #${editor.story.actors.length + 1}';
  } else {
    actor = Actor.fromJson(value.toJson());
    name = editor.tr.actor(actor);
  }

  return showEditorSheet<Actor>(
    context: context,
    title: value == null ? 'Create a character' : 'Edit character',
    initial: value,
    onSave: () {
      editor.story.actors[actor.id] = actor;
      editor.tr[actor.id] = name;
      return actor;
    },
    onDelete: value == null
        ? null
        : () {
            editor.story.actors.remove(value.id);
            editor.tr.assets.remove(value.id);
          },
    builder: (context, setState) {
      void setType(ActorType? v) => setState(() {
            actor.type = v ?? actor.type;
          });
      return [
        ListTile(
          leading: const Icon(Icons.label_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Character name',
            ),
            autofocus: true,
            initialValue: name,
            validator: emptyValidator,
            onChanged: (s) => name = s.trim(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.link_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Avatar file URL',
            ),
            autofocus: true,
            initialValue: actor.avatarUrl,
            onChanged: (s) => actor.avatarUrl = s.trim(),
          ),
        ),
        buildExplanationTile(
          context,
          'Character mode',
          'Sets the look of its messages, restricts some options for them.',
        ),
        RadioListTile<ActorType>(
          value: ActorType.npc,
          groupValue: actor.type,
          onChanged: setType,
          secondary: const Icon(Icons.smart_toy_rounded),
          title: const Text('Computer character'),
          subtitle: const Text('Follows the narrative'),
        ),
        RadioListTile<ActorType>(
          value: ActorType.player,
          groupValue: actor.type,
          onChanged: setType,
          secondary: const Icon(Icons.face_rounded),
          title: const Text('Player character'),
          subtitle: const Text('Controlled by the player'),
        ),
      ];
    },
  );
}
