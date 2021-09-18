import 'package:algolia/algolia.dart';

class ScenarioHit {
  final String scenarioID;
  final String translationID;
  final String title;
  final String? description;

  const ScenarioHit({
    required this.scenarioID,
    required this.translationID,
    required this.title,
    this.description,
  });

  factory ScenarioHit.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;
    return ScenarioHit(
      scenarioID: json['scenarioID'],
      translationID: json['translationID'],
      title: json['title'],
      description: json['description'],
    );
  }
}
