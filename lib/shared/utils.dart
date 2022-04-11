import 'package:algolia/algolia.dart';
import 'package:andax/models/story.dart';
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

List<StoryInfo> storiesFromSnapshot(AlgoliaQuerySnapshot qs) {
  return qs.hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}
