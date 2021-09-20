import 'package:andax/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum ContentStatus { public, unlisted, private, pending }

class ContentMetaData {
  String id;
  List<String> contributorsIds;
  Timestamp lastUpdateAt;
  int likes;
  ContentStatus status;

  ContentMetaData({
    required this.id,
    Timestamp? lastUpdateAt,
    this.contributorsIds = const [],
    this.likes = 0,
    this.status = ContentStatus.private,
  }) : this.lastUpdateAt = lastUpdateAt ?? Timestamp.now();

  ContentMetaData.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          id: id,
          contributorsIds: listFromJson(
            json['contributorsIds'],
            (c) => c as String,
          ),
          lastUpdateAt: json['lastUpdateAt'] as Timestamp,
          likes: json['likes'] ?? 0,
          status: EnumToString.fromString(
                  ContentStatus.values, json['status'] ?? '') ??
              ContentStatus.private,
        );

  Map<String, dynamic> toJson() {
    return {
      'contributorsIds': contributorsIds,
      'lastUpdateAt': lastUpdateAt,
      'likes': likes,
      'status': EnumToString.convertToString(status),
    };
  }
}
