import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/story_editor.dart';

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
