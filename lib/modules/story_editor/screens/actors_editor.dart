import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/actor_editor_dialog.dart';
import 'package:flutter/material.dart';

class StoryActorsEditorScreen extends StatefulWidget {
  const StoryActorsEditorScreen(
    this.editor, {
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;

  @override
  _StoryActorsEditorScreenState createState() =>
      _StoryActorsEditorScreenState();
}

class _StoryActorsEditorScreenState extends State<StoryActorsEditorScreen> {
  @override
  Widget build(BuildContext context) {
    final actors = widget.editor.story.actors.values.toList();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Story actors'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showActorEditorDialog(
          context,
          widget.editor,
          (r) => setState(() {}),
        ),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add actor'),
      ),
      body: ListView.builder(
          itemCount: actors.length,
          itemBuilder: (context, i) {
            final actor = actors[i];
            return ListTile(
              onTap: () => showActorEditorDialog(
                context,
                widget.editor,
                (r) => setState(() {}),
                actor,
              ),
              leading: Icon(actor.type == ActorType.npc
                  ? Icons.smart_toy_rounded
                  : Icons.face_rounded),
              title: Text(ActorTranslation.getName(
                widget.editor.translation,
                actor.id,
              )),
            );
          }),
    );
  }
}
