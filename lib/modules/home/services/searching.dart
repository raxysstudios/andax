import 'package:algolia/algolia.dart';
import 'package:andax/models/story.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/store.dart';

String _generateFilter(
  Iterable<String> values, [
  String filter = 'tags',
  bool and = false,
]) {
  final joint = and ? 'AND' : 'OR';
  final tags = values.map((v) => '$filter:"$v"');
  return tags.join(' $joint ');
}

AlgoliaQuery formQuery(String index, String text) {
  final tags = <String>[];
  final words = <String>[];
  text.split(' ').forEach((e) {
    if (e.startsWith('#')) {
      if (e != '#') {
        tags.add(e.substring(1));
      }
    } else if (e.isNotEmpty) {
      words.add(e);
    }
  });
  var query = algolia.index(index).query(words.join(' '));
  if (tags.isNotEmpty) {
    query = query.filters(_generateFilter(tags, 'tags', true));
  }
  return query;
}

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
