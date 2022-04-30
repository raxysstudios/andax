import 'package:andax/models/story.dart';
import 'package:andax/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/profile.dart';

Future<List<LikeItem>> getLikes(
  User user, {
  int page = 0,
  int? hitsPerPage = 20,
  LikeItem? last,
}) async {
  var query = FirebaseFirestore.instance
      .collection('users/${user.uid}/likes')
      .orderBy('date', descending: true);
  if (hitsPerPage != null) query = query.limit(hitsPerPage);
  if (last != null) query = query.startAfterDocument(last.key);

  final likes = await query.get().then((r) => r.docs).then(
        (docs) => {for (final d in docs) d.id: d},
      );
  final stories = await algolia.instance
      .index('stories')
      .getObjectsByIds(likes.keys.toList())
      .then((s) => s.map(StoryInfo.fromAlgoliaHit))
      .catchError((dynamic e) => <StoryInfo>[]);

  return stories.map((s) => MapEntry(likes[s.translationID]!, s)).toList();
}

Future<List<StoryInfo>> getStories(
  User user, {
  int page = 0,
  int? hitsPerPage,
  StoryInfo? last,
}) async {
  var query = algolia.instance
      .index('stories')
      .query('')
      .filters(
        'storyAuthorID:${user.uid}',
      )
      .setFacetingAfterDistinct()
      .setDistinct(value: 1)
      .setPage(page);
  if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);

  final hits = await query.getObjects().then((r) => r.hits);
  return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}

Future<List<StoryInfo>> getTranslations(
  User user, {
  int page = 0,
  int? hitsPerPage,
  StoryInfo? last,
}) async {
  var query = algolia.instance
      .index('stories')
      .query('')
      .filters('translationAuthorID:${user.uid}')
      .setPage(page);
  if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);

  final hits = await query.getObjects().then((r) => r.hits);
  return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}

Future<int> updateLikes(User user) {
  return FirebaseFirestore.instance
      .doc('users/${user.uid}')
      .get()
      .then((r) => r.data()?['likes'] as int? ?? 0);
}

Future<int> updateStories(User user) {
  return algolia.instance
      .index('stories')
      .query('')
      .filters('storyAuthorID:${user.uid}')
      .setHitsPerPage(0)
      .setFacetingAfterDistinct()
      .setDistinct(value: 1)
      .getObjects()
      .then((r) => r.nbHits);
}

Future<int> updateTranslations(User user) {
  return algolia.instance
      .index('stories')
      .query('')
      .filters('translationAuthorID:${user.uid}')
      .setHitsPerPage(0)
      .getObjects()
      .then((r) => r.nbHits);
}
