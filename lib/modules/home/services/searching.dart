import 'package:algolia/algolia.dart';

String generateFilter(
  Iterable<String> values, [
  String filter = 'tags',
  bool and = false,
]) {
  final joint = and ? 'AND' : 'OR';
  final tags = values.map((v) => '$filter:"$v"');
  return tags.join(' $joint ');
}

AlgoliaQuery parseQuery(AlgoliaIndexReference index, String query) {
  final tags = <String>[];
  final words = <String>[];
  query.split(' ').forEach((e) {
    if (e.startsWith('#')) {
      if (e != '#') {
        tags.add(e.substring(1));
      }
    } else if (e.isNotEmpty) {
      words.add(e);
    }
  });
  return index
      .query(words.join(' '))
      .filters(generateFilter(tags, 'tags', true));
}
