import 'package:andax/models/translation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/loading_dialog.dart';

Future<Translation> loadTranslation(StoryInfo info) async {
  final tdc = FirebaseFirestore.instance.doc(
    'stories/${info.storyID}/translations/${info.translationID}',
  );
  final assets = await tdc
      .collection('assets')
      .withConverter<TranslationAsset>(
        fromFirestore: (snapshot, _) => TranslationAsset.fromJson(
          snapshot.data()!,
          snapshot.id,
        ),
        toFirestore: (scenario, _) => scenario.toJson(),
      )
      .get();
  return await tdc.get().then(
        (r) => Translation.fromJson(
          r.data()!,
          id: r.id,
          assets: {
            for (final asset in assets.docs) asset.id: asset.data(),
          },
        ),
      );
}

Future<Story> loadStory(StoryInfo info) async {
  final document = await FirebaseFirestore.instance
      .doc('stories/${info.storyID}')
      .withConverter<Story>(
        fromFirestore: (snapshot, _) => Story.fromJson(
          snapshot.data()!,
          id: snapshot.id,
        ),
        toFirestore: (story, _) => story.toJson(),
      )
      .get();
  return document.data()!;
}

Future<void> loadExperience(
  BuildContext context,
  StoryInfo info,
  Future<void> Function(Story, Translation) onLoaded,
) async {
  Story? story;
  Translation? translation;
  await showLoadingDialog<void>(
    context,
    (() async {
      story = await loadStory(info);
      translation = await loadTranslation(info);
    })(),
  );
  if (story != null && translation != null) {
    await onLoaded(story!, translation!);
  }
}
