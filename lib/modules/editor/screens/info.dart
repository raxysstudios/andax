import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/home/screens/home.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/snackbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/story.dart';
import '../services/story.dart';

class InfoEditorScreen extends StatelessWidget {
  const InfoEditorScreen({Key? key}) : super(key: key);

  void promptStoryDelete(
    BuildContext context,
    StoryEditorState editor,
  ) async {
    final confirmed = await showDangerDialog(
      context,
      'Completely delete the story and all of its translations?',
    );
    if (confirmed) {
      await showLoadingDialog(context, deleteStory(editor));
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const HomeScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Story info'),
        actions: [
          if (editor.info != null)
            IconButton(
              onPressed: () => promptStoryDelete(context, editor),
              tooltip: 'Delete story',
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showLoadingDialog(context, uploadStory(editor));
          showSnackbar(
            context,
            icon: Icons.cloud_done_rounded,
            text: 'Uploaded!',
          );
        },
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Save story'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 72),
        children: [
          ListTile(
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Initial language',
                prefixIcon: Icon(Icons.language_rounded),
              ),
              initialValue: editor.translation.language,
              onChanged: (s) {
                editor.translation.language = s;
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              initialValue: StoryTranslation.get(editor.translation)?.title,
              onChanged: (s) {
                StoryTranslation.get(editor.translation)?.title = s;
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Story description',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              initialValue:
                  StoryTranslation.get(editor.translation)?.description,
              onChanged: (s) {
                StoryTranslation.get(editor.translation)?.description = s;
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Story tags',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              initialValue: prettyTags(
                StoryTranslation.get(editor.translation)?.tags,
                separator: ' ',
              ),
              onChanged: (s) {
                StoryTranslation.get(editor.translation)?.tags =
                    s.split(' ').where((t) => t.isNotEmpty).toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}
