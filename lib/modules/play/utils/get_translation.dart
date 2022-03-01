import 'package:andax/models/translation_asset.dart';

String getTranslation<T extends TranslationAsset>(
  Map<String, TranslationAsset> translations,
  String id,
  String? Function(T) getter,
) {
  final asset = translations[id] as T?;
  return asset == null ? '' : getter(asset) ?? '';
}
