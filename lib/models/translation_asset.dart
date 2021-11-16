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

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'title': title,
        'description': description,
      });
  }
}

class MessageTranslation extends TranslationAsset {
  String? text;
  String? audioUrl;

  MessageTranslation({
    this.text,
    this.audioUrl,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.message);

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'text': text,
        'audioUrl': audioUrl,
      });
  }
}

class ActorTranslation extends TranslationAsset {
  String name;

  ActorTranslation({
    this.name = "",
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.actor);

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'name': name,
      });
  }
}
