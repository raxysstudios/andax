import 'package:andax/models/content_meta_data.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum AssetType {
  message,
  scenario,
  actor,
}

abstract class TranslationAsset {
  final AssetType assetType;
  final ContentMetaData metaData;

  const TranslationAsset({
    required this.assetType,
    required this.metaData,
  });

  static TranslationAsset? get(
    Map<String, TranslationAsset> set,
    String id,
  ) =>
      set[id];

  factory TranslationAsset.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final type = EnumToString.fromString(
      AssetType.values,
      json['assetType'],
    );
    final metaData = ContentMetaData.fromJson(
      json['metaData'],
      id: id,
    );

    switch (type) {
      case AssetType.message:
        return MessageTranslation(
          text: json['text'],
          audioUrl: json['audioUrl'],
          metaData: metaData,
        );
      case AssetType.actor:
        return ActorTranslation(
          name: json['name'],
          metaData: metaData,
        );
      case AssetType.scenario:
        return ScenarioTranslation(
          title: json['title'],
          description: json['description'],
          metaData: metaData,
        );
      default:
        return MessageTranslation(
          text: 'ERROR',
          metaData: metaData,
        );
    }
  }

  Map<String, dynamic> toJson() => {
        'assetType': EnumToString.convertToString(assetType),
        'metaData': metaData.toJson(),
      };
}

class ScenarioTranslation extends TranslationAsset {
  String title;
  String? description;

  ScenarioTranslation({
    required this.title,
    this.description,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.scenario);

  static ScenarioTranslation? get(Map<String, TranslationAsset> set) =>
      set['scenario'] as ScenarioTranslation?;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'title': title,
      'description': description,
    });
}

class MessageTranslation extends TranslationAsset {
  String? text;
  String? audioUrl;

  MessageTranslation({
    this.text,
    this.audioUrl,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.message);

  static MessageTranslation? get(
    Map<String, TranslationAsset> set,
    String id,
  ) =>
      set[id] as MessageTranslation?;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'text': text,
      'audioUrl': audioUrl,
    });
}

class ActorTranslation extends TranslationAsset {
  String name;

  ActorTranslation({
    this.name = "",
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.actor);

  static ActorTranslation? get(
    Map<String, TranslationAsset> set,
    String id,
  ) =>
      set[id] as ActorTranslation?;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'name': name,
    });
}
