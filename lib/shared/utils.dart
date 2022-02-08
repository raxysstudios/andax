import 'package:andax/shared/extensions.dart';

String? prettyTags(
  Iterable<String>? tags, {
  String separator = ' • ',
  bool capitalized = true,
}) {
  if (tags == null) return null;
  final text = tags.join(separator);
  return capitalized ? text.titleCase : text;
}
