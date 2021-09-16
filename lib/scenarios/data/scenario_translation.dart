import 'package:enum_to_string/enum_to_string.dart';
import 'content_meta_data.dart';

enum TranslationType { text, audio }

class ScenarioTranslation {
  String language;
  String scenarioId;
  TranslationType type;
  Map<String, String> assets;
  ContentMetaData metaData;

  ScenarioTranslation({
    required this.scenarioId,
    required this.language,
    required this.type,
    required this.metaData,
    required this.assets,
  });

  ScenarioTranslation.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          scenarioId: json['scenarioId'],
          language: json['language'],
          type: EnumToString.fromString(
                TranslationType.values,
                json['type'],
              ) ??
              TranslationType.text,
          assets: Map.castFrom<String, dynamic, String, String>(
            json['assets'] as Map<String, dynamic>,
          ),
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'scenarioId': scenarioId,
      'assets': assets,
      'metaData': metaData.toJson(),
    };
  }
}
