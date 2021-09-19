import 'package:andax/models/content_meta_data.dart';

enum AssetKind {
  Message,
  Scenario,
  Actor,
}

class TranslationAsset {
  final AssetKind assetKind;
  final ContentMetaData metaData;

  const TranslationAsset({
    required this.metaData,
    required this.assetKind,
  });
}

class ScenarioTranslation extends TranslationAsset {
  final String title;
  final String description;

  const ScenarioTranslation({
    required this.title,
    required this.description,
    required ContentMetaData metaData,
    required AssetKind assetKind,
  })  : assert(assetKind == AssetKind.Scenario),
        super(metaData: metaData, assetKind: assetKind);
}

class MessageTranslation extends TranslationAsset {
  final String text;
  final String audioUrl;

  const MessageTranslation({
    required this.text,
    required this.audioUrl,
    required ContentMetaData metaData,
    required AssetKind assetKind,
  })  : assert(assetKind == AssetKind.Message),
        super(metaData: metaData, assetKind: assetKind);
}

class ActorTranslation extends TranslationAsset {
  final String name;

  const ActorTranslation({
    required this.name,
    required ContentMetaData metaData,
    required AssetKind assetKind,
  })  : assert(assetKind == AssetKind.Message),
        super(metaData: metaData, assetKind: assetKind);
}
