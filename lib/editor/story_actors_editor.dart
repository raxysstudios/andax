import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryActorsEditor extends StatelessWidget {
  const StoryActorsEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Actors: ${editor.story.actors.length}'),
          forceElevated: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final actor = editor.story.actors[index];
              if (actor == null) return const SizedBox();
              return ListTile(
                leading: IconButton(
                  onPressed: () => editor.update(() {
                    actor.type = actor.type == ActorType.npc
                        ? ActorType.player
                        : ActorType.npc;
                  }),
                  icon: Icon(actor.type == ActorType.npc
                      ? Icons.smart_toy_outlined
                      : Icons.face_outlined),
                ),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Actor name',
                  ),
                  initialValue: ActorTranslation.get(
                    editor.translation,
                    actor.id,
                  )?.name,
                  onChanged: (s) => editor.update(() {
                    final t =
                        ActorTranslation.get(editor.translation, actor.id);
                    if (t != null) t.name = s;
                  }),
                ),
                trailing: IconButton(
                  onPressed: () => editor.update(() {
                    editor.story.actors.remove(actor);
                    editor.translation.assets.remove(actor.id);
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
            childCount: editor.story.actors.length,
          ),
        )
      ],
    );
  }
}
