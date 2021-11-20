import 'package:andax/utils.dart';
import 'actor.dart';
import 'content_meta_data.dart';
import 'node.dart';
import 'package:algolia/algolia.dart';

class Story {
  Map<String, Node> nodes;
  Map<String, Actor> actors;
  String startNodeId;
  ContentMetaData metaData;

  Story({
    required this.nodes,
    required this.startNodeId,
    required this.actors,
    required this.metaData,
  });

  Story.fromJson(
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

  Map<String, dynamic> toJson() => {
        'startNodeId': startNodeId,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'actors': actors.values.map((a) => a.toJson()).toList(),
        'metaData': metaData.toJson(),
      };
}

class StoryInfo {
  final String storyID;
  final String translationID;
  final String title;
  final String? description;

  const StoryInfo({
    required this.storyID,
    required this.translationID,
    required this.title,
    this.description,
  });

  factory StoryInfo.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;
    return StoryInfo(
      storyID: json['storyID'],
      translationID: json['translationID'],
      title: json['title'],
      description: json['description'],
    );
  }
}
