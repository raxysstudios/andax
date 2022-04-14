import 'package:andax/models/story.dart';
import 'package:andax/shared/utils.dart';
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
) async {
  var language = '';
  var title = '';
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create translation'),
        content: Column(
          children: [
            TextField(
              onChanged: (s) => language = s.trim(),
              decoration: const InputDecoration(
                labelText: 'Translation language',
              ),
            ),
            TextField(
              onChanged: (s) => title = s.trim(),
              decoration: const InputDecoration(
                labelText: 'Translated title',
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              language = '';
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirm'),
          ),
        ],
      );
    },
  );
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || language.isEmpty) return null;

  final doc = await FirebaseFirestore.instance
      .collection('stories/${info.storyID}/translations')
      .add(<String, dynamic>{
    'language': language,
    'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
    'metaData.authorId': user.uid,
  });
  return StoryInfo(
    storyID: info.storyID,
    storyAuthorID: info.storyAuthorID,
    translationID: doc.id,
    translationAuthorID: user.uid,
    title: title,
  );
}
