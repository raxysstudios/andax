import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum AssetType {
  message,
  story,
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
    Translation translation,
    String id,
  ) =>
      translation[id];

  factory TranslationAsset.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final type = EnumToString.fromString(
      AssetType.values,
      json['assetType'] as String,
    );
    final metaData = ContentMetaData.fromJson(
      json['metaData'] as Map<String, dynamic>,
      id: id,
    );

    switch (type) {
      case AssetType.message:
        return MessageTranslation(
          text: json['text'] as String,
          audioUrl: json['audioUrl'] as String,
          metaData: metaData,
        );
      case AssetType.actor:
        return ActorTranslation(
          name: json['name'] as String,
          metaData: metaData,
        );
      case AssetType.story:
        return StoryTranslation(
          title: json['title'] as String,
          description: json['description'] as String,
          metaData: metaData,
        );
      default:
        return MessageTranslation(
          text: 'ERROR',
          metaData: metaData,
        );
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'assetType': EnumToString.convertToString(assetType),
        'metaData': metaData.toJson(),
      };
}

class StoryTranslation extends TranslationAsset {
  String title;
  String? description;

  StoryTranslation({
    required this.title,
    this.description,
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.story);

  static StoryTranslation? get(
    Translation translation,
  ) =>
      translation['story'] as StoryTranslation?;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll(<String, dynamic>{
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
    Translation translation,
    String id,
  ) =>
      translation[id] as MessageTranslation?;

  static String getText(
    Translation translation,
    String id,
  ) =>
      get(translation, id)?.text ?? 'None';

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll(<String, dynamic>{
      'text': text,
      'audioUrl': audioUrl,
    });
}

class ActorTranslation extends TranslationAsset {
  String name;

  ActorTranslation({
    this.name = '',
    required ContentMetaData metaData,
  }) : super(metaData: metaData, assetType: AssetType.actor);

  static ActorTranslation? get(
    Translation translation,
    String id,
  ) =>
      translation[id] as ActorTranslation?;

  static String getName(
    Translation translation,
    String id, [
    String or = 'None',
  ]) =>
      get(translation, id)?.name ?? or;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll(<String, dynamic>{
      'name': name,
    });
}
