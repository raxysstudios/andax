List<T> listFromJson<T>(
  Object? array,
  T Function(dynamic) fromJson,
) =>
    (array as Iterable<dynamic>?)?.map(fromJson).toList() ?? [];

List<String>? json2list(Object? array) {
  return (array as Iterable<dynamic>?)
      ?.map((dynamic i) => i as String)
      .toList();
}

String capitalize(String? text) {
  if (text == null) return '';
  return text
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ')
      .split('-')
      .where((s) => s.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join('-');
}

String? prettyTags(
  Iterable<String>? tags, {
  String separator = ' • ',
  bool capitalized = true,
}) {
  if (tags == null) return null;
  final text = tags.join(separator);
  return capitalized ? capitalize(text) : text;
}
