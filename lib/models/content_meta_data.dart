import 'package:andax/utils.dart';
import 'package:enum_to_string/enum_to_string.dart';

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
          likes: json['likes'] ?? 0,
          status: EnumToString.fromString(
                  ContentStatus.values, json['status'] ?? '') ??
              ContentStatus.private,
        );

  Map<String, dynamic> toJson() {
    return {
      'contributorsIds': contributorsIds,
      'lastUpdateAt': lastUpdateAt.millisecondsSinceEpoch,
      'likes': likes,
      'status': EnumToString.convertToString(status),
    };
  }
}
