import 'package:algolia/algolia.dart';
import 'package:json_annotation/json_annotation.dart';

import 'actor.dart';
import 'node.dart';

part 'story.g.dart';

@JsonSerializable(explicitToJson: true)
class Story {
  @JsonKey(name: 'nodes')
  List<Node> _nodes;
  @JsonKey(name: 'actors')
  List<Actor> _actors;
  Map<String, Node> get nodes => {for (final node in _nodes) node.id: node};
  Map<String, Actor> get actors =>
      {for (final actor in _actors) actor.id: actor};
  String startNodeId;

  Story({
    required List<Node> nodes,
    required this.startNodeId,
    required List<Actor> actors,
  })  : _nodes = nodes,
        _actors = actors;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
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
