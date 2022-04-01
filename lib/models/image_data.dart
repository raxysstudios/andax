import 'dart:core';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_data.g.dart';

@JsonSerializable()
class ImageData {
  String url;
  double height;
  BoxFit fit;
  @JsonKey(fromJson: _alignmentFromJson, toJson: _alignmentToJson)
  Alignment alignment;

  ImageData({
    this.url = '',
    this.height = 128,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}

final _$AlignmentEnumMap = {
  Alignment.topCenter: 'topCenter',
  Alignment.center: 'center',
  Alignment.bottomCenter: 'bottomCenter',
};
Alignment _alignmentFromJson(String json) => _$AlignmentEnumMap.entries
    .firstWhere(
      (e) => e.value == json,
      orElse: () => _$AlignmentEnumMap.entries.first,
    )
    .key;
String _alignmentToJson(Alignment alignment) {
  return _$AlignmentEnumMap[alignment] ?? 'center';
}
