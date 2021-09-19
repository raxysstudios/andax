import 'package:andax/models/content_meta_data.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum AssetType {
  Message,
  Scenario,
  Actor,
}

abstract class TranslationAsset {
  final AssetType assetType;
  final ContentMetaData metaData;

  const TranslationAsset({
    required this.metaData,
    required this.assetType,
  });

  factory TranslationAsset.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final type = EnumToString.fromString(
      AssetType.values,
      json['assetType'],
    );
    switch (type) {
      case AssetType.Message:
        return MessageTranslation(
          text: json['text'],
          audioUrl: json['audioUrl'],
          metaData: ContentMetaData.fromJson(json['metaData'], id: id),
        );
      case AssetType.Actor:
        return ActorTranslation(
          name: json['name'],
          metaData: ContentMetaData.fromJson(json['metaData'], id: id),
        );
      case AssetType.Scenario:
        return ScenarioTranslation(
          title: json['title'],
          description: json['description'],
          metaData: ContentMetaData.fromJson(json['metaData'], id: id),
        );
      default:
        return MessageTranslation(
          text: 'ERROR',
          metaData: ContentMetaData(
            id: id,
            lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(1),
          ),
        );
    }
  }

  Map<String, dynamic> toJson() {
    final type = EnumToString.convertToString(assetType);
    return {
      'type': type,
      'metaData': metaData.toJson(),
    };
  }
}

class ScenarioTranslation extends TranslationAsset {
  final String title;
  final String? description;

  const ScenarioTranslation({
    required this.title,
    this.description,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.Scenario);

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'title': title,
        'description': description,
      });
  }
}

class MessageTranslation extends TranslationAsset {
  final String? text;
  final String? audioUrl;

  const MessageTranslation({
    this.text,
    this.audioUrl,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.Message);

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'text': text,
        'audioUrl': audioUrl,
      });
  }
}

class ActorTranslation extends TranslationAsset {
  final String name;

  const ActorTranslation({
    required this.name,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.Message);

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'name': name,
      });
  }
}
