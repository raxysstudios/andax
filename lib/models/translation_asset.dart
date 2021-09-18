import 'package:andax/models/content_meta_data.dart';

enum AssetKind {
  Message,
  Scenario,
  Author,
}

class TranslationAsset {
  final AssetKind assetKind;
  final ContentMetaData metaData;

  const TranslationAsset({
    required this.metaData,
    required this.assetKind,
  });
}

class ScenarioAsset extends TranslationAsset {
  final String title;
  final String description;

  const ScenarioAsset({
    required this.title,
    required this.description,
    required ContentMetaData metaData,
    required AssetKind assetKind,
  })  : assert(assetKind == AssetKind.Scenario),
        super(metaData: metaData, assetKind: assetKind);
}

class MessageAsset extends TranslationAsset {
  final String text;
  final String audioUrl;

  const MessageAsset({
    required this.text,
    required this.audioUrl,
    required ContentMetaData metaData,
    required AssetKind assetKind,
  })  : assert(assetKind == AssetKind.Message),
        super(metaData: metaData, assetKind: assetKind);
}
