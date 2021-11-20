import 'package:andax/models/translation_asset.dart';

import 'content_meta_data.dart';

class Translation {
  String language;
  ContentMetaData metaData;
  Map<String, TranslationAsset> assets;

  Translation({
    required this.language,
    required this.metaData,
    required this.assets,
  });

  Translation.fromJson(
    Map<String, dynamic> json, {
    required String id,
    Map<String, TranslationAsset>? assets,
  }) : this(
          language: json['language'],
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
          assets: assets ?? {},
        );

  Map<String, dynamic> toJson() => {
        'language': language,
        'metaData': metaData.toJson(),
      };
}
