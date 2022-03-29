import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<Translation> loadTranslation(StoryInfo info) async {
  final tdc = FirebaseFirestore.instance.doc(
    'stories/${info.storyID}/translations/${info.translationID}',
  );
  final assets = await tdc.collection('assets').get();
  return await tdc.get().then(
        (r) => Translation.fromJson(<String, dynamic>{
          'id': r.id,
          'assets': <String, dynamic>{
            for (final asset in assets.docs) asset.id: asset.data()['text'],
          },
          ...r.data()!,
        }),
      );
}

Future<Story> loadNarrative(StoryInfo info) async {
  final document = await FirebaseFirestore.instance
      .doc('stories/${info.storyID}')
      .withConverter<Story>(
        fromFirestore: (snapshot, _) => Story.fromJson(<String, dynamic>{
          'id': snapshot.id,
          ...snapshot.data()!,
        }),
        toFirestore: (story, _) => story.toJson(),
      )
      .get();
  return document.data()!;
}

Future<void> loadStory(
  BuildContext context,
  StoryInfo info,
  Future<void> Function(Story, Translation) onLoaded,
) async {
  Story? story;
  Translation? translation;
  await showLoadingDialog<void>(
    context,
    (() async {
      story = await loadNarrative(info);
      translation = await loadTranslation(info);
    })(),
  );
  if (story != null && translation != null) {
    await onLoaded(story!, translation!);
  }
}
