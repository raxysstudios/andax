import 'package:andax/utils.dart';
import 'content_meta_data.dart';
import 'scenario_node.dart';

class Scenario {
  String title;
  String? description;
  List<ScenarioNode> nodes;
  String startNodeId;
  Map<String, String>? texts;
  Map<String, String>? audios;
  ContentMetaData metaData;

  Scenario({
    required this.title,
    this.description,
    required this.nodes,
    required this.startNodeId,
    this.texts,
    this.audios,
    required this.metaData,
  });

  Scenario.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          title: json['title'],
          description: json['description'],
          nodes: listFromJson(
            json['notes'],
            (j) => ScenarioNode.fromJson(j),
          ),
          startNodeId: json['startNodeId'],
          texts: Map.castFrom<String, dynamic, String, String>(
            json['texts'] as Map<String, dynamic>,
          ),
          audios: Map.castFrom<String, dynamic, String, String>(
            json['audios'] as Map<String, dynamic>,
          ),
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startNodeId': startNodeId,
      'nodes': nodes.map((n) => n.toJson()),
      'texts': texts,
      'audios': audios,
      'metaData': metaData.toJson(),
    };
  }
}
