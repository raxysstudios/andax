import 'package:andax/models/translation_asset.dart';
import 'package:json_annotation/json_annotation.dart';

import 'content_meta_data.dart';

part 'translation.g.dart';

@JsonSerializable()
class Translation {
  String language;
  final ContentMetaData metaData;
  final Map<String, TranslationAsset> assets;

  Translation({
    required this.language,
    required this.metaData,
    this.assets = const {},
  });

  TranslationAsset? operator [](String id) => assets[id];
  void operator []=(String id, TranslationAsset asset) => assets[id] = asset;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson([bool withMeta = false]) {
    final json = _$TranslationToJson(this)..remove('assets');
    if (!withMeta) json.remove('metadata');
    return json;
  }
}
