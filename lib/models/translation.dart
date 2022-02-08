import 'package:andax/models/translation_asset.dart';

import 'content_meta_data.dart';

class Translation {
  String language;
  final ContentMetaData metaData;
  final Map<String, TranslationAsset> assets;

  Translation({
    required this.language,
    required this.metaData,
    required this.assets,
  });

  TranslationAsset? operator [](String id) => assets[id];
  operator []=(String id, TranslationAsset asset) {
    assets[id] = asset;
  }

  Translation.fromJson(
    Map<String, dynamic> json, {
    required String id,
    Map<String, TranslationAsset>? assets,
  }) : this(
          language: json['language'] as String,
          metaData: ContentMetaData.fromJson(
            json['metaData'] as Map<String, dynamic>,
            id: id,
          ),
          assets: assets ?? {},
        );

  Map<String, dynamic> toJson([bool withMeta = false]) => <String, dynamic>{
        'language': language,
        'metaData': metaData.toJson(),
        if (withMeta) 'metaData': metaData.toJson(),
      };
}
