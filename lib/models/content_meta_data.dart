import 'package:andax/utils.dart';

enum ContentStatus { public, unlisted, private, pending }

class ContentMetaData {
  String id;
  List<String> contributorsIds;
  DateTime lastUpdateAt;
  int likes;
  ContentStatus status;

  ContentMetaData({
    required this.id,
    required this.lastUpdateAt,
    this.contributorsIds = const [],
    this.likes = 0,
    this.status = ContentStatus.private,
  });

  ContentMetaData.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          id: id,
          contributorsIds: listFromJson(
            json['contributorsIds'],
            (c) => c as String,
          ),
          lastUpdateAt: json['lastUpdateAt'].toDate(),
          likes: int.parse(json['likes']),
        );

  Map<String, dynamic> toJson() {
    return {
      'contributorsIds': contributorsIds,
      'lastUpdateAt': lastUpdateAt.millisecondsSinceEpoch,
      'likes': likes,
      'status': status,
    };
  }
}
