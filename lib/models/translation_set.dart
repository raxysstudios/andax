import 'package:enum_to_string/enum_to_string.dart';
import 'content_meta_data.dart';

enum TranslationType { text, audio }

class TranslationSet {
  String language;
  bool isPrimary;
  TranslationType type;
  ContentMetaData metaData;

  TranslationSet({
    required this.language,
    required this.type,
    required this.metaData,
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
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isPrimary': isPrimary,
      'metaData': metaData.toJson(),
    };
  }
}
