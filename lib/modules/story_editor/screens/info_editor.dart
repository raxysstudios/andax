import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/widgets/actor_editor_dialog.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/narrative_list_view.dart';
import 'narrative_editor.dart';

class StoryInfoEditor extends StatefulWidget {
  const StoryInfoEditor({Key? key}) : super(key: key);

  @override
  State<StoryInfoEditor> createState() => _StoryInfoEditorState();
}

class _StoryInfoEditorState extends State<StoryInfoEditor> {
  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final translation = editor.translation;
    final story = editor.story;

    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(icon: Icons.done_all_rounded),
        title: const Text('Story Info'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActorEditorDialog(
          context,
          (r) => setState(() {}),
        ),
        tooltip: 'Add actor',
        child: const Icon(Icons.person_add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 72),
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Initial language',
              ),
              initialValue: translation.language,
              onChanged: (s) {
                translation.language = s;
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.title_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story title',
              ),
              initialValue: StoryTranslation.get(translation)?.title,
              onChanged: (s) {
                StoryTranslation.get(translation)?.title = s;
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story description',
              ),
              initialValue: StoryTranslation.get(translation)?.description,
              onChanged: (s) {
                StoryTranslation.get(translation)?.description = s;
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story tags',
              ),
              initialValue: prettyTags(
                StoryTranslation.get(translation)?.tags,
                separator: ' ',
              ),
              onChanged: (s) {
                StoryTranslation.get(translation)?.tags =
                    s.split(' ').where((t) => t.isNotEmpty).toList();
              },
            ),
          ),
          ListTile(
            onTap: () async {
              final node = await showStoryNodePickerSheet(
                editor,
                context,
                story.startNodeId,
              );
              setState(() {
                story.startNodeId = node?.id ?? '';
              });
            },
            leading: const Icon(Icons.login_rounded),
            title: Text(
              MessageTranslation.getText(
                translation,
                story.startNodeId,
              ),
            ),
          ),
          const Divider(),
          for (final actor in story.actors.values)
            ListTile(
              onTap: () => showActorEditorDialog(
                context,
                (r) => setState(() {}),
                actor,
              ),
              leading: Icon(actor.type == ActorType.npc
                  ? Icons.smart_toy_rounded
                  : Icons.face_rounded),
              title: Text(ActorTranslation.getName(translation, actor.id)),
            )
        ],
      ),
    );
  }
}
