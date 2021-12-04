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
              (dynamic j) => Node.fromJson(j as Map<String, dynamic>),
            ))
              node.id: node
          },
          startNodeId: json['startNodeId'] as String,
          actors: {
            for (final actor in listFromJson(
              json['actors'],
              (dynamic j) => Actor.fromJson(j as Map<String, dynamic>),
            ))
              actor.id: actor
          },
          metaData: ContentMetaData.fromJson(
            json['metaData'] as Map<String, dynamic>,
            id: id,
          ),
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
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
      storyID: json['storyID'] as String,
      translationID: json['translationID'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }
}
