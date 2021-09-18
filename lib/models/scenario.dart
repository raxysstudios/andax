import 'package:andax/utils.dart';
import 'actor.dart';
import 'content_meta_data.dart';
import 'node.dart';

class Scenario {
  List<Node> nodes;
  String startNodeId;
  List<Actor> actors;
  ContentMetaData metaData;

  Scenario({
    this.nodes = const [],
    required this.startNodeId,
    this.actors = const [],
    required this.metaData,
  });

  Scenario.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          nodes: listFromJson(
            json['nodes'],
            (j) => Node.fromJson(j),
          ),
          startNodeId: json['startNodeId'],
          actors: listFromJson(
            json['actors'],
            (j) => Actor.fromJson(j),
          ),
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'startNodeId': startNodeId,
      'nodes': nodes.map((n) => n.toJson()),
      'actors': actors.map((a) => a.toJson()),
      'metaData': metaData.toJson(),
    };
  }
}

class ScenarioInfo {
  final String id;
  final String title;
  final String description;

  ScenarioInfo({
    required this.id,
    required this.title,
    required this.description,
  });
}
