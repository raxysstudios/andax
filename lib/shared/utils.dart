import 'package:andax/shared/extensions.dart';

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

String? prettyTags(
  Iterable<String>? tags, {
  String separator = ' • ',
  bool capitalized = true,
}) {
  if (tags == null) return null;
  final text = tags.join(separator);
  return capitalized ? text.titleCase : text;
}
