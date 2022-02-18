import 'package:algolia/algolia.dart';
import 'package:andax/models/story.dart';
import 'package:andax/store.dart';

Future<List<StoryInfo>> getStories(
  String index, {
  int? page,
  int? hitsPerPage,
}) async {
  var query = algolia.instance.index(index).query('');
  if (page != null) query = query.setPage(page);
  if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);
  final qs = await query.getObjects();
  return storiesFromSnapshot(qs);
}

List<StoryInfo> storiesFromSnapshot(AlgoliaQuerySnapshot qs) {
  return qs.hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}
