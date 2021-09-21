import 'content_meta_data.dart';

class TranslationSet {
  String language;
  ContentMetaData metaData;

  TranslationSet({
    required this.language,
    required this.metaData,
  });

  TranslationSet.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) : this(
          language: json['language'],
          metaData: ContentMetaData.fromJson(
            json['metaData'],
            id: id,
          ),
        );

  Map<String, dynamic> toJson() => {
        'language': language,
        'metaData': metaData.toJson(),
      };
}
