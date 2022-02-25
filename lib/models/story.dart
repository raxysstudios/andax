import 'package:algolia/algolia.dart';
import 'package:json_annotation/json_annotation.dart';

import 'actor.dart';
import 'node.dart';

part 'story.g.dart';

@JsonSerializable(explicitToJson: true)
class Story {
  @JsonKey(toJson: _nodesToJson)
  Map<String, Node> nodes;
  @JsonKey(toJson: _actorsToJson)
  Map<String, Actor> actors;
  String? startNodeId;

  Story({
    this.startNodeId,
    required List<Node> nodes,
    required List<Actor> actors,
  })  : nodes = {for (final node in nodes) node.id: node},
        actors = {for (final actor in actors) actor.id: actor};

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);

  static List<Map<String, dynamic>> _nodesToJson(Map<String, Node> nodes) =>
      nodes.values.map((node) => node.toJson()).toList();

  static List<Map<String, dynamic>> _actorsToJson(Map<String, Actor> actors) =>
      actors.values.map((node) => node.toJson()).toList();
}

// Workaround since json_serializable doesn't support constructor tearoff
DateTime? _dateFromMillis(int? millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

@JsonSerializable()
class StoryInfo {
  final String storyID;
  final String storyAuthorID;
  final String translationID;
  final String translationAuthorID;
  final String title;
  final String? description;
  final List<String>? tags;
  final String? imageUrl;
  final int likes;
  final int views;
  @JsonKey(fromJson: _dateFromMillis)
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
    this.imageUrl,
  });

  factory StoryInfo.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;
    return _$StoryInfoFromJson(json);
  }
}
