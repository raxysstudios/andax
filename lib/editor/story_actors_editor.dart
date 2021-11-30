import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActorsEditor extends StatelessWidget {
  const ActorsEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final actors = editor.story.actors.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Actors'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editor.update(() {
          final id = editor.uuid.v4();
          editor.story.actors[id] = Actor(id: id);
          editor.translation[id] = ActorTranslation(metaData: editor.meta);
        }),
        tooltip: 'Add actor',
        child: const Icon(Icons.person_add_rounded),
      ),
      body: ListView.builder(
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return ListTile(
            leading: IconButton(
              onPressed: () => editor.update(() {
                actor.type = actor.type == ActorType.npc
                    ? ActorType.player
                    : ActorType.npc;
              }),
              icon: Icon(actor.type == ActorType.npc
                  ? Icons.smart_toy_rounded
                  : Icons.face_rounded),
            ),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Actor name',
              ),
              initialValue: ActorTranslation.getName(
                editor.translation,
                actor.id,
                '',
              ),
              onChanged: (s) => editor.update(() {
                ActorTranslation.get(
                  editor.translation,
                  actor.id,
                )?.name = s;
              }),
            ),
            trailing: IconButton(
              onPressed: () => editor.update(() {
                editor.story.actors.remove(actor.id);
                editor.translation.assets.remove(actor.id);
              }),
              icon: const Icon(Icons.clear_rounded),
            ),
          );
        },
      ),
    );
  }
}
