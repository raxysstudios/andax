import 'dart:core';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_data.g.dart';

@JsonSerializable()
class ImageData {
  String url;
  BoxFit fit;

  ImageData({
    this.url = '',
    this.fit = BoxFit.cover,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}
