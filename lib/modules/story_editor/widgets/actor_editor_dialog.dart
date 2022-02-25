import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';

void showActorEditorDialog(
  BuildContext context,
  StoryEditorState editor,
  ValueSetter<Actor?> onResult, [
  Actor? value,
]) {
  late Actor actor;
  late ActorTranslation translation;

  if (value == null) {
    final id = editor.uuid.v4();
    actor = Actor(id: id);
    translation = ActorTranslation(
      id: id,
      name: 'Actor #${editor.story.actors.length}',
    );
  } else {
    actor = Actor.fromJson(value.toJson());
    translation = ActorTranslation.get(editor.translation, actor.id)!;
  }

  showEditorDialog<Actor>(
    context,
    result: () => actor,
    callback: (result) {
      if (result == null) {
        if (value != null) {
          editor.story.actors.remove(value.id);
          editor.translation.assets.remove(value.id);
        }
      } else {
        editor.story.actors[result.id] = result;
        editor.translation[result.id] = translation;
      }
      onResult(result);
    },
    title: 'Edit actor',
    padding: EdgeInsets.zero,
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
              translation.name = s;
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
          selected: actor.type == ActorType.npc,
          onTap: () => setState(() {
            actor.type = ActorType.npc;
          }),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          horizontalTitleGap: 12,
          leading: const Icon(Icons.smart_toy_rounded),
          title: const Text('NPC actor'),
          subtitle: const Text('Follows the narrative'),
        ),
        ListTile(
          selected: actor.type == ActorType.player,
          onTap: () => setState(() {
            actor.type = ActorType.player;
          }),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          horizontalTitleGap: 12,
          leading: const Icon(Icons.face_rounded),
          title: const Text('Payer actor'),
          subtitle: const Text('Controller by the player'),
        ),
      ];
    },
  );
}
