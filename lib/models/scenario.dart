import 'package:andax/models/translation_asset.dart';
import 'package:andax/utils.dart';
import 'actor.dart';
import 'content_meta_data.dart';
import 'node.dart';
import 'package:algolia/algolia.dart';

class Scenario {
  Map<String, Node> nodes;
  Map<String, Actor> actors;
  String startNodeId;
  ContentMetaData metaData;

  Scenario({
    required this.nodes,
    required this.startNodeId,
    required this.actors,
    required this.metaData,
  });

  Scenario.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          nodes: {
            for (final node in listFromJson(
              json['nodes'],
              (j) => Node.fromJson(j),
            ))
              node.id: node
          },
          startNodeId: json['startNodeId'],
          actors: {
            for (final actor in listFromJson(
              json['actors'],
              (j) => Actor.fromJson(j),
            ))
              actor.id: actor
          },
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'startNodeId': startNodeId,
      'nodes': nodes.values.map((n) => n.toJson()).toList(),
      'actors': actors.values.map((a) => a.toJson()).toList(),
      'metaData': metaData.toJson(),
    };
  }
}

class ScenarioInfo {
  final String scenarioID;
  final String translationID;
  final String title;
  final String? description;

  const ScenarioInfo({
    required this.scenarioID,
    required this.translationID,
    required this.title,
    this.description,
  });

  factory ScenarioInfo.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;
    return ScenarioInfo(
      scenarioID: json['scenarioID'],
      translationID: json['translationID'],
      title: json['title'],
      description: json['description'],
    );
  }
}
