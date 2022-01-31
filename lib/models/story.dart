import 'package:andax/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      };
}

class StoryInfo {
  final String storyID;
  final String storyAuthorID;
  final String translationID;
  final String translationAuthorID;
  final String title;
  final String? description;
  final List<String>? tags;
  final int likes;
  final int views;
  final DateTime? lastUpdateAt;

  const StoryInfo({
    required this.storyID,
    required this.storyAuthorID,
    required this.translationID,
    required this.translationAuthorID,
    required this.title,
    this.description,
    this.likes = 0,
    this.views = 0,
    this.tags,
    this.lastUpdateAt,
  });

  factory StoryInfo.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;
    return StoryInfo(
      storyID: json['storyID'] as String,
      storyAuthorID: json['storyAuthorID'] as String,
      translationID: json['translationID'] as String,
      translationAuthorID: json['translationAuthorID'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      tags: json2list(json['tags']),
      lastUpdateAt: (json['lastUpdateAt'] as Timestamp?)?.toDate(),
    );
  }
}
