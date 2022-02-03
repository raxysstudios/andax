import 'package:andax/store.dart';

import 'package:andax/models/story.dart';

Future<List<StoryInfo>> getStories(
  String index, {
  int? page,
  int? hitsPerPage,
}) async {
  var query = algolia.instance.index(index).query('');
  if (page != null) query = query.setPage(page);
  if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);
  final hits = await query.getObjects().then((s) => s.hits);
  return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}
