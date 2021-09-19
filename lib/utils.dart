import 'models/translation_asset.dart';

List<T> listFromJson<T>(
  Object? array,
  T Function(dynamic) fromJson,
) {
  return (array as Iterable<dynamic>?)?.map(fromJson).toList() ?? [];
}

String getTranslation<T extends TranslationAsset>(
  Map<String, TranslationAsset> translations,
  String id,
  String? Function(T) getter,
) {
  final asset = translations[id] as T?;
  return asset == null ? '' : getter(asset) ?? '';
}
