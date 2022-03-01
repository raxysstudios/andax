import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/actor_editor_dialog.dart';
import '../widgets/actor_tile.dart';
import 'story_editor.dart';

class StoryActorsEditorScreen extends StatelessWidget {
  const StoryActorsEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final actors = editor.story.actors.values.toList();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Story actors'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showActorEditorDialog(context).then((r) => editor.setState(() {})),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add actor'),
      ),
      body: ListView.builder(
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return ActorTile(
            actor,
            onTap: () => showActorEditorDialog(context, actor)
                .then((r) => editor.setState(() {})),
            index: index,
          );
        },
      ),
    );
  }
}
