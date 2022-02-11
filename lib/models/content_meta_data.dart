import 'package:andax/shared/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum ContentStatus { public, unlisted, private, pending }

class ContentMetaData {
  String id;
  List<String> contributorsIds;
  String authorId;
  String? imageUrl;
  Timestamp lastUpdateAt;
  int likes;
  int views;
  int lastIndexedViews;
  ContentStatus status;

  ContentMetaData(
    this.id,
    this.authorId, {
    this.imageUrl,
    this.contributorsIds = const [],
    Timestamp? lastUpdateAt,
    this.likes = 0,
    this.views = 0,
    this.lastIndexedViews = 0,
    this.status = ContentStatus.private,
  }) : lastUpdateAt = lastUpdateAt ?? Timestamp.now();

  ContentMetaData.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          id,
          json['authorId'] as String? ?? '',
          imageUrl: json['imageUrl'] as String?,
          contributorsIds: listFromJson(
            json['contributorsIds'],
            (dynamic c) => c as String,
          ),
          lastUpdateAt: json['lastUpdateAt'] as Timestamp,
          likes: json['likes'] as int? ?? 0,
          views: json['views'] as int? ?? 0,
          lastIndexedViews: json['lastIndexedViews'] as int? ?? 0,
          status: EnumToString.fromString(
                ContentStatus.values,
                json['status'] as String? ?? '',
              ) ??
              ContentStatus.private,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'contributorsIds': contributorsIds,
        'authorId': authorId,
        'imageUrl': imageUrl,
        'lastUpdateAt': lastUpdateAt,
        'likes': likes,
        'views': views,
        'lastIndexedViews': lastIndexedViews,
        'status': EnumToString.convertToString(status),
      };
}
