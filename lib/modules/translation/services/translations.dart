import 'package:andax/models/story.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<List<StoryInfo>> getAllTranslations(String storyId) async {
  final query = algolia.index('stories').filters('storyID:$storyId');
  final snapshot = await query.getObjects();
  return storiesFromSnapshot(snapshot);
}

Future<StoryInfo?> createTranslation(
  BuildContext context,
  StoryInfo info,
  String language,
  String title,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || language.isEmpty) return null;

  final doc = await showLoadingDialog(
    context,
    (() async {
      final doc = await FirebaseFirestore.instance
          .collection('stories/${info.storyID}/translations')
          .add(<String, dynamic>{
        'language': language,
        'metaData': {
          'lastUpdateAt': FieldValue.serverTimestamp(),
          'authorId': user.uid,
        }
      });
      await doc
          .collection('assets')
          .doc('title')
          .set(<String, String>{'text': title});
      return doc;
    })(),
  );
  if (doc == null) return null;
  return StoryInfo(
    storyID: info.storyID,
    storyAuthorID: info.storyAuthorID,
    translationID: doc.id,
    translationAuthorID: user.uid,
    title: title,
  );
}
