import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/story.dart';
import 'models/translation_asset.dart';

Future<List<TranslationAsset>> loadTranslations(
  StoryInfo scenarioInfo,
) async {
  final collection = await FirebaseFirestore.instance
      .collection(
          'scenarios/${scenarioInfo.scenarioID}/translations/${scenarioInfo.translationID}/assets')
      .withConverter<TranslationAsset>(
        fromFirestore: (snapshot, _) =>
            TranslationAsset.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (scenario, _) => scenario.toJson(),
      )
      .get();
  return collection.docs.map((doc) => doc.data()).toList();
}

Future<Story> loadScenario(StoryInfo scenarioInfo) async {
  final document = await FirebaseFirestore.instance
      .doc('scenarios/${scenarioInfo.scenarioID}')
      .withConverter<Story>(
        fromFirestore: (snapshot, _) =>
            Story.fromJson(snapshot.data()!, id: snapshot.id),
        toFirestore: (scenario, _) => scenario.toJson(),
      )
      .get();
  return document.data()!;
}
