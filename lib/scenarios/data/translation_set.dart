import 'package:enum_to_string/enum_to_string.dart';
import 'content_meta_data.dart';

enum TranslationType { text, audio }

class TranslationSet {
  String language;
  bool isPrimary;
  TranslationType type;
  Map<String, String> assets;
  ContentMetaData metaData;

  TranslationSet({
    required this.language,
    required this.type,
    required this.metaData,
    required this.assets,
    this.isPrimary = false,
  });

  TranslationSet.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          language: json['language'],
          isPrimary: json['isPrimary'],
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
      'isPrimary': isPrimary,
      'assets': assets,
      'metaData': metaData.toJson(),
    };
  }
}
