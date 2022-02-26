import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/actor_editor_dialog.dart';
import 'package:andax/modules/story_editor/widgets/actor_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        onPressed: () => showActorEditorDialog(
          context,
          editor,
          (r) => editor.setState(() {}),
        ),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add actor'),
      ),
      body: ListView.builder(
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return ActorTile(
            actor,
            editor,
            onTap: () => showActorEditorDialog(
              context,
              editor,
              (r) => editor.setState(() {}),
              actor,
            ),
            index: index,
          );
        },
      ),
    );
  }
}
