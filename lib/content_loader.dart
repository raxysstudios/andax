import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/scenario.dart';
import 'models/translation_asset.dart';

Future<List<TranslationAsset>> loadTranslations(
  ScenarioInfo scenarioInfo,
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

Future<Scenario> loadScenario(ScenarioInfo scenarioInfo) async {
  final document = await FirebaseFirestore.instance
      .doc('scenarios/${scenarioInfo.scenarioID}')
      .withConverter<Scenario>(
        fromFirestore: (snapshot, _) =>
            Scenario.fromJson(snapshot.data()!, id: snapshot.id),
        toFirestore: (scenario, _) => scenario.toJson(),
      )
      .get();
  return document.data()!;
}
