import 'package:andax/models/story.dart';
import 'package:andax/modules/home/services/sheets.dart';
import 'package:andax/modules/home/widgets/story_tile.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart' as flutterfire_auth;

import '../config/auth_providers.dart';

typedef LikeItem = MapEntry<DocumentSnapshot, StoryInfo>;

class ProfileScreen extends StatefulWidget {
  final User _user;

  const ProfileScreen(this._user, {Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User get user => widget._user;
  int? likes;
  int? stories;
  int? translations;

  @override
  void initState() {
    super.initState();
    updateCounters();
  }

  Future<void> updateCounters() async {
    Future<void> updateLikes() async {
      likes = await FirebaseFirestore.instance
          .doc('users/${user.uid}')
          .get()
          .then((r) => r.data()?['likes'] as int? ?? 0);
      setState(() {});
    }

    Future<void> updateStories() async {
      stories = await algolia.instance
          .index('stories')
          .query('')
          .filters('storyAuthorID:${user.uid}')
          .setHitsPerPage(0)
          .getObjects()
          .then((r) => r.nbHits);
      setState(() {});
    }

    Future<void> updateTranslations() async {
      translations = await algolia.instance
          .index('stories')
          .query('')
          .filters('translationAuthorID:${user.uid}')
          .setHitsPerPage(0)
          .getObjects()
          .then((r) => r.nbHits);
      setState(() {});
    }

    await Future.wait([
      updateLikes(),
      updateStories(),
      updateTranslations(),
    ]);
  }

  Widget loadingChip(int? value) {
    return Chip(
      label: value == null
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(),
            )
          : Text(value.toString()),
    );
  }

  Widget buildStoriesTile(
    IconData icon,
    String title,
    int? count,
    Future<List<StoryInfo>> Function(int page, StoryInfo? last) getter,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: loadingChip(count),
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: const RoundedBackButton(),
              title: Text(title),
            ),
            body: PagingList<StoryInfo>(
              onRequest: getter,
              builder: (context, info, index) {
                return StoryTile(
                  info,
                  onTap: () => showStorySheet(context, info),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return flutterfire_auth.ProfileScreen(
      providerConfigs: providerConfigs,
      avatarSize: 100,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.favorite_rounded),
          title: const Text('Liked stories'),
          trailing: loadingChip(likes),
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  leading: const RoundedBackButton(),
                  title: const Text('Liked Stories'),
                ),
                body: PagingList<LikeItem>(
                  onRequest: getLikes,
                  builder: (context, item, index) {
                    return StoryTile(
                      item.value,
                      onTap: () => showStorySheet(context, item.value),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        buildStoriesTile(
          Icons.history_edu_rounded,
          'Created stories',
          stories,
          getStories,
        ),
        buildStoriesTile(
          Icons.translate_rounded,
          'Created translations',
          translations,
          getTranslations,
        ),
        const Divider(),
      ],
    );
  }

  Future<List<LikeItem>> getLikes(int page, LikeItem? last) async {
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

  Future<List<StoryInfo>> getStories(int page, StoryInfo? last) async {
    final hits = await algolia.instance
        .index('stories')
        .query('')
        .filters('storyAuthorID:${user.uid}')
        .setPage(page)
        .getObjects()
        .then((r) => r.hits);
    return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
  }

  Future<List<StoryInfo>> getTranslations(int page, StoryInfo? last) async {
    final hits = await algolia.instance
        .index('stories')
        .query('')
        .filters('translationAuthorID:${user.uid}')
        .setPage(page)
        .getObjects()
        .then((r) => r.hits);
    return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
  }
}
