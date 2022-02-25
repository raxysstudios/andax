import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/home/screens/home.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/node_picker_sheet.dart';
import 'story_editor.dart';

class StoryInfoEditor extends StatefulWidget {
  const StoryInfoEditor(
    this.editor, {
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;

  @override
  State<StoryInfoEditor> createState() => _StoryInfoEditorState();
}

class _StoryInfoEditorState extends State<StoryInfoEditor> {
  StoryEditorState get editor => widget.editor;
  Translation get translation => editor.translation;
  Story get story => editor.story;

  Future<void> uploadStory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final sdb = FirebaseFirestore.instance.collection('stories');
    var sid = editor.info?.storyID;
    if (sid == null) {
      sid = await sdb.add(story.toJson()).then((r) => r.id);
    } else {
      await sdb.doc(editor.info?.storyID).update(story.toJson());
    }
    await sdb.doc(sid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final tdb = sdb.doc(sid).collection('translations');
    var tid = editor.info?.translationID;
    if (tid == null) {
      tid = await tdb.add(translation.toJson()).then((r) => r.id);
    } else {
      await tdb.doc(tid).update(translation.toJson());
    }
    await tdb.doc(tid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final adb = tdb.doc(tid).collection('assets');
    await Future.wait([
      for (final entry in translation.assets.entries)
        adb.doc(entry.key).set(entry.value.toJson())
    ]);
    editor.info ??= StoryInfo(
      storyID: sid!,
      storyAuthorID: '',
      translationID: tid!,
      translationAuthorID: '',
      title: '',
    );
  }

  Future<void> deleteStory() async {
    if (editor.info == null) return;
    final story = FirebaseFirestore.instance.doc(
      'stories/' + editor.info!.storyID,
    );
    final translations = await story.collection('translations').get();
    for (final t in translations.docs) {
      final assets = await t.reference.collection('assets').get();
      for (final a in assets.docs) {
        await a.reference.delete();
      }
      t.reference.delete();
    }
    story.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Story info'),
        actions: [
          if (editor.info != null)
            IconButton(
              onPressed: () async {
                bool delete = await showDangerDialog(
                  context,
                  'Completely delete the story and all of its translations?',
                );
                if (delete) {
                  await showLoadingDialog(context, deleteStory());
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const HomeScreen();
                      },
                    ),
                  );
                }
              },
              tooltip: 'Delete story',
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showLoadingDialog(context, uploadStory());
          Navigator.pop(context);
        },
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload story'),
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
              final node = await showNodePickerSheet(
                context,
                editor,
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
            subtitle: const Text('Starting node'),
          ),
        ],
      ),
    );
  }
}
