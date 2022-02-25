import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/narrative_editor.dart';
import 'package:andax/shared/widgets/editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showActorEditorDialog(
  BuildContext context,
  ValueSetter<Actor?> onResult, [
  Actor? value,
]) {
  final editor = context.read<StoryEditorState>();
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
    children: [
      // ListTile(
      //   leading: IconButton(
      //     onPressed: () => setState(() {
      //       actor.type =
      //           actor.type == ActorType.npc ? ActorType.player : ActorType.npc;
      //     }),
      //     icon: Icon(actor.type == ActorType.npc
      //         ? Icons.smart_toy_rounded
      //         : Icons.face_rounded),
      //   ),
      // ),
      TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.short_text_rounded),
          labelText: 'Actor name',
        ),
        initialValue: translation.name,
        validator: emptyValidator,
        onChanged: (s) {
          translation.name = s;
        },
      ),
    ],
  );
}