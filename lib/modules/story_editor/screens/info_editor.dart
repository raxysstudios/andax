import 'package:andax/models/story.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/home/screens/home.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'story_editor.dart';

class StoryInfoEditorScreen extends StatelessWidget {
  const StoryInfoEditorScreen({Key? key}) : super(key: key);

  Future<void> uploadStory(StoryEditorState editor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final sdb = FirebaseFirestore.instance.collection('stories');
    var sid = editor.info?.storyID;
    if (sid == null) {
      sid = await sdb.add(editor.story.toJson()).then((r) => r.id);
    } else {
      await sdb.doc(editor.info?.storyID).update(editor.story.toJson());
    }
    await sdb.doc(sid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final tdb = sdb.doc(sid).collection('translations');
    var tid = editor.info?.translationID;
    if (tid == null) {
      tid = await tdb.add(editor.translation.toJson()).then((r) => r.id);
    } else {
      await tdb.doc(tid).update(editor.translation.toJson());
    }
    await tdb.doc(tid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final adb = tdb.doc(tid).collection('assets');
    await Future.wait([
      for (final entry in editor.translation.assets.entries)
        adb.doc(entry.key).set(entry.value.toJson())
    ]);
    editor.setState(() {
      editor.info ??= StoryInfo(
        storyID: sid!,
        storyAuthorID: '',
        translationID: tid!,
        translationAuthorID: '',
        title: '',
      );
    });
  }

  Future<void> deleteStory(StoryEditorState editor) async {
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
    final editor = context.watch<StoryEditorState>();
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
              },
              tooltip: 'Delete story',
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showLoadingDialog(context, uploadStory(editor));
          Navigator.pop(context);
        },
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload story'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 72),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Initial language',
              prefixIcon: Icon(Icons.language_rounded),
            ),
            initialValue: editor.translation.language,
            onChanged: (s) {
              editor.translation.language = s;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Story title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
            initialValue: StoryTranslation.get(editor.translation)?.title,
            onChanged: (s) {
              StoryTranslation.get(editor.translation)?.title = s;
            },
          ),
          TextFormField(
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Story description',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            initialValue: StoryTranslation.get(editor.translation)?.description,
            onChanged: (s) {
              StoryTranslation.get(editor.translation)?.description = s;
            },
          ),
          TextFormField(
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
        ],
      ),
    );
  }
}
