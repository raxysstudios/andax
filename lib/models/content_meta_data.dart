import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content_meta_data.g.dart';

enum ContentStatus { public, unlisted, private, pending }

DateTime _timestampToDate(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateToTimestamp(DateTime date) => Timestamp.fromDate(date);

@JsonSerializable()
class ContentMetaData {
  final String id;
  final List<String> contributorsIds;
  @JsonKey(defaultValue: '')
  final String authorId;
  final String? imageUrl;
  @JsonKey(fromJson: _timestampToDate, toJson: _dateToTimestamp)
  final DateTime lastUpdateAt;
  final int likes;
  final int views;
  final int lastIndexedViews;
  final ContentStatus status;

  ContentMetaData(
    this.id,
    this.authorId, {
    this.imageUrl,
    this.contributorsIds = const [],
    DateTime? lastUpdateAt,
    this.likes = 0,
    this.views = 0,
    this.lastIndexedViews = 0,
    this.status = ContentStatus.private,
  }) : lastUpdateAt = lastUpdateAt ?? DateTime.now();

  factory ContentMetaData.fromJson(Map<String, dynamic> json) =>
      _$ContentMetaDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContentMetaDataToJson(this)..remove('id');
}
