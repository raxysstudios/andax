import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/translation/widgets/translation_creator.dart';
import 'package:andax/modules/translation/widgets/translation_selector.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/translations.dart';

Future<List<StoryInfo>> getAllTranslations(String storyId) async {
  final query = algolia.index('stories').filters('storyID:$storyId');
  final snapshot = await query.getObjects();
  return storiesFromSnapshot(snapshot);
}

Future<void> selectBaseTranslation(
  BuildContext context,
  StoryInfo target,
) async {
  final base = await showTranslationSelector(context, target);
  if (base != null) openTranslationEditor(context, base, target);
}

Future<void> addTranslation(
  BuildContext context,
  StoryInfo base,
) async {
  final target = await showTranslationCreator(context, base);
  if (target != null) openTranslationEditor(context, base, target);
}

Future<void> openTranslationEditor(
  BuildContext context,
  StoryInfo base,
  StoryInfo target,
) async {
  late final Story narrative;
  late final Translation baseTranslation;
  late final Translation targetTranslation;
  await showLoadingDialog(
    context,
    (() async {
      narrative = await loadNarrative(base);
      baseTranslation = await loadTranslation(base);
      targetTranslation = await loadTranslation(target);
    })(),
  );
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return TranslationEditorScreen(
          info: target,
          narrative: narrative,
          base: baseTranslation,
          target: targetTranslation,
        );
      },
    ),
  );
}

Future<StoryInfo?> createTranslation(
  BuildContext context,
  StoryInfo info,
  String language,
  String title,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc = await showLoadingDialog(
    context,
    (() async {
      final doc = await FirebaseFirestore.instance
          .collection('stories/${info.storyID}/translations')
          .add(<String, dynamic>{
        'language': language,
        'metaData': {
          'lastUpdateAt': FieldValue.serverTimestamp(),
          'authorId': uid,
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
    translationAuthorID: uid,
    title: title,
    language: language,
  );
}
