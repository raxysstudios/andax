import 'package:andax/models/translation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translation_asset.g.dart';

enum AssetType {
  message,
  story,
  actor,
}

@JsonSerializable(createFactory: false)
abstract class TranslationAsset {
  final String id;
  final AssetType assetType;

  const TranslationAsset({
    required this.id,
    required this.assetType,
  });

  static TranslationAsset? get(
    Translation translation,
    String id,
  ) =>
      translation[id];

  factory TranslationAsset.fromJson(Map<String, dynamic> json) {
    final type = _$AssetTypeEnumMap.entries
        .firstWhere((element) => element.value == json['assetType'] as String)
        .key;

    switch (type) {
      case AssetType.message:
        return MessageTranslation.fromJson(json);
      case AssetType.actor:
        return ActorTranslation.fromJson(json);
      case AssetType.story:
        return StoryTranslation.fromJson(json);
      default:
        return MessageTranslation(
          id: json['id'] as String,
          text: 'ERROR',
        );
    }
  }

  Map<String, dynamic> toJson() => _$TranslationAssetToJson(this)..remove('id');
}

@JsonSerializable()
class StoryTranslation extends TranslationAsset {
  String title;
  String? description;
  List<String>? tags;

  StoryTranslation({
    required String id,
    required this.title,
    this.description,
    this.tags,
  }) : super(id: id, assetType: AssetType.story);

  factory StoryTranslation.fromJson(Map<String, dynamic> json) =>
      _$StoryTranslationFromJson(json);

  static StoryTranslation? get(
    Translation translation,
  ) =>
      translation['story'] as StoryTranslation?;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$StoryTranslationToJson(this));
}

@JsonSerializable()
class MessageTranslation extends TranslationAsset {
  String? text;
  String? audioUrl;

  MessageTranslation({
    required String id,
    this.text,
    this.audioUrl,
  }) : super(id: id, assetType: AssetType.message);

  factory MessageTranslation.fromJson(Map<String, dynamic> json) =>
      _$MessageTranslationFromJson(json);

  static MessageTranslation? get(
    Translation translation,
    String id,
  ) =>
      translation[id] as MessageTranslation?;

  static String getText(
    Translation translation,
    String id, [
    String ifNull = 'None',
  ]) =>
      get(translation, id)?.text ?? ifNull;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$MessageTranslationToJson(this));
}

@JsonSerializable()
class ActorTranslation extends TranslationAsset {
  String name;

  ActorTranslation({
    required String id,
    this.name = '',
  }) : super(id: id, assetType: AssetType.actor);

  factory ActorTranslation.fromJson(Map<String, dynamic> json) =>
      _$ActorTranslationFromJson(json);

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
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$ActorTranslationToJson(this));
}
