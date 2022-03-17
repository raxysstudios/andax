import 'package:andax/models/story.dart';
import 'package:andax/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/profile.dart';

Future<List<LikeItem>> getLikes(
  User user,
  int page,
  LikeItem? last,
) async {
  var query = FirebaseFirestore.instance
      .collection('users/${user.uid}/likes')
      // This seems to break `startAfterDocument`: https://github.com/FirebaseExtended/flutterfire/issues/7946
      // .orderBy('date', descending: true)
      .limit(20);
  if (last != null) query = query.startAfterDocument(last.key);

  final likes = await query.get().then((r) => r.docs);
  if (likes.isEmpty) return [];

  final stories = await algolia.instance
      .index('stories')
      .query('')
      .filters(
        likes
            .map((l) => l.data()['translationID'] as String)
            .map((t) => 'translationID:$t')
            .join(' OR '),
      )
      .getObjects()
      .then(
        (s) => s.hits.map((h) => StoryInfo.fromAlgoliaHit(h)),
      )
      .then((ss) => ({for (final s in ss) s.translationID: s}));

  return [
    for (final like in likes)
      MapEntry(
        like,
        stories[like.data()['translationID'] as String]!,
      )
  ];
}

Future<List<StoryInfo>> getStories(
  User user,
  int page,
  StoryInfo? last,
) async {
  final hits = await algolia.instance
      .index('stories')
      .query('')
      .filters('storyAuthorID:${user.uid}')
      .setPage(page)
      .getObjects()
      .then((r) => r.hits);
  return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}

Future<List<StoryInfo>> getTranslations(
  User user,
  int page,
  StoryInfo? last,
) async {
  final hits = await algolia.instance
      .index('stories')
      .query('')
      .filters('translationAuthorID:${user.uid}')
      .setPage(page)
      .getObjects()
      .then((r) => r.hits);
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
