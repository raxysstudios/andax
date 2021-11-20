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
    final actors = editor.story.actors.values.toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text('Actors: ${actors.length}'),
          forceElevated: true,
          floating: true,
          snap: true,
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
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
                  initialValue: ActorTranslation.get(
                    editor.translation,
                    actor.id,
                  )?.name,
                  onChanged: (s) => editor.update(() {
                    final t = ActorTranslation.get(
                      editor.translation,
                      actor.id,
                    );
                    if (t != null) t.name = s;
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
            childCount: actors.length,
          ),
        ),
      ],
    );
  }
}
