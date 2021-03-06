import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/story.dart';

Future<void> uploadStory(StoryEditorState editor) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

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
    tid = await tdb.add(editor.tr.toJson()).then((r) => r.id);
  } else {
    await tdb.doc(tid).update(editor.tr.toJson());
  }
  await tdb.doc(tid).update({
    'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
    'metaData.authorId': uid,
  });

  final adb = tdb.doc(tid).collection('assets');
  await Future.wait([
    for (final entry in editor.tr.assets.entries)
      adb.doc(entry.key).set(<String, String>{'text': entry.value})
  ]);
  editor.setState(
    () => editor.info ??= StoryInfo(
      storyID: sid!,
      storyAuthorID: uid,
      translationID: tid!,
      translationAuthorID: uid,
      title: editor.tr.title,
      language: editor.tr.language,
    ),
  );
}

Future<void> deleteStory(StoryEditorState editor) async {
  final info = editor.info;
  if (info == null) return;
  final callDeleteStory =
      FirebaseFunctions.instanceFor(region: 'europe-central2')
          .httpsCallable('deleteStory');
  await callDeleteStory(info.storyID);
}
