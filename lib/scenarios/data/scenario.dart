import 'package:andax/utils.dart';
import 'actor.dart';
import 'content_meta_data.dart';
import 'node.dart';

class Scenario {
  Map<String, Actor>? actors;
  List<Node> nodes;
  String startNodeId;
  ContentMetaData metaData;

  Scenario({
    required this.nodes,
    required this.startNodeId,
    this.actors,
    required this.metaData,
  });

  Scenario.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          nodes: listFromJson(
            json['notes'],
            (j) => Node.fromJson(j),
          ),
          startNodeId: json['startNodeId'],
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'startNodeId': startNodeId,
      'nodes': nodes.map((n) => n.toJson()),
      'metaData': metaData.toJson(),
    };
  }
}
