import 'package:algolia/algolia.dart';

String _generateFilter(
  Iterable<String> values, [
  String filter = 'tags',
  bool and = false,
]) {
  final joint = and ? 'AND' : 'OR';
  final tags = values.map((v) => '$filter:"$v"');
  return tags.join(' $joint ');
}

AlgoliaQuery formQuery(AlgoliaIndexReference index, String text) {
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
  var query = index.query(words.join(' '));
  if (tags.isNotEmpty) {
    query = query.filters(_generateFilter(tags, 'tags', true));
  }
  return query;
}
