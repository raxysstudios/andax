import 'package:andax/modules/home/screens/home.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/editor_sheet.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/snackbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';
import '../services/story.dart';

class InfoEditorScreen extends StatefulWidget {
  const InfoEditorScreen({Key? key}) : super(key: key);

  @override
  State<InfoEditorScreen> createState() => _InfoEditorScreenState();
}

class _InfoEditorScreenState extends State<InfoEditorScreen> {
  final form = GlobalKey<FormState>();

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
          if (!(form.currentState?.validate() ?? true)) return;
          if (editor.story.nodes.isEmpty) {
            showSnackbar(
              context,
              Icons.error_rounded,
              'Error: Empty narrative!',
            );
            return;
          }
          await showLoadingDialog(context, uploadStory(editor));
          showSnackbar(context, Icons.cloud_done_rounded, 'Uploaded!');
        },
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Save story'),
      ),
      body: Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 72),
          children: [
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Initial language',
                ),
                initialValue: editor.tr.language,
                validator: emptyValidator,
                onChanged: (s) => editor.tr.language = s.trim(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.title_rounded),
              title: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Story title',
                ),
                initialValue: editor.tr.title,
                validator: emptyValidator,
                onChanged: (s) => editor.tr['title'] = s.trim(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cover image url',
                ),
                initialValue: editor.story.coverUrl,
                onChanged: (s) => editor.story.coverUrl = s.trim(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: TextFormField(
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Story description',
                ),
                initialValue: editor.tr.description,
                onChanged: (s) => editor.tr['description'] = s.trim(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tag_rounded),
              title: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Story tags',
                ),
                initialValue: editor.tr['tags'],
                onChanged: (s) => editor.tr['tags'] = s.trim(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
