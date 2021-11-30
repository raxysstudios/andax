import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:andax/widgets/rounded_back_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';
import 'narrative_list_view.dart';

class StoryGeneralEditor extends StatelessWidget {
  const StoryGeneralEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('General'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showLoadingDialog(context, editor.upload());
          Navigator.pop(context);
        },
        tooltip: 'Upload story',
        child: const Icon(Icons.upload_rounded),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Initial language',
              ),
              initialValue: editor.translation.language,
              onChanged: (s) => editor.update(() {
                editor.translation.language = s;
              }),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.title_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story title',
              ),
              initialValue: StoryTranslation.get(editor.translation)?.title,
              onChanged: (s) => editor.update(() {
                StoryTranslation.get(editor.translation)?.title = s;
              }),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story description',
              ),
              initialValue:
                  StoryTranslation.get(editor.translation)?.description,
              onChanged: (s) => editor.update(() {
                StoryTranslation.get(editor.translation)?.description = s;
              }),
            ),
          ),
          ListTile(
            onTap: () => showStoryNodePickerSheet(
              context,
              editor.story.startNodeId,
            ).then(
              (node) => editor.update(() {
                editor.story.startNodeId = node?.id ?? '';
              }),
            ),
            leading: const Icon(Icons.login_rounded),
            title: Text(
              MessageTranslation.getText(
                editor.translation,
                editor.story.startNodeId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
