enum ContentStatus { public, unlisted, private }

class ContentMetaData {
  String id;
  String authorId;
  DateTime lastUpdateAt;
  int likes;
  ContentStatus status;

  ContentMetaData({
    required this.id,
    required this.authorId,
    required this.lastUpdateAt,
    this.likes = 0,
    this.status = ContentStatus.public,
  });

  ContentMetaData.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          id: id,
          authorId: json['authorId'],
          lastUpdateAt: json['lastUpdateAt'].toDate(),
          likes: int.parse(json['likes']),
        );

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'lastUpdateAt': lastUpdateAt.millisecondsSinceEpoch,
      'likes': likes,
      'status': status,
    };
  }
}
