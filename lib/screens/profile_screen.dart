import 'dart:convert';
import 'dart:math';

import 'package:andax/models/story.dart';
import 'package:andax/screens/story_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/widgets/paging_list.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:andax/widgets/sing_in_buttons.dart';
import 'package:andax/widgets/story_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef LikeItem = MapEntry<DocumentSnapshot, StoryInfo>;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get user => FirebaseAuth.instance.currentUser;
  int? likes;

  Future<void> updateLikes() async {
    likes = user == null
        ? null
        : await FirebaseFirestore.instance
            .doc('users/${user!.uid}')
            .get()
            .then((r) => r.get('likes') as int);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          SignInButtons(
            onSignOut: updateLikes,
            onSingIn: updateLikes,
          ),
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
              ),
              title: Text(user!.displayName ?? '[no name]'),
              subtitle: Text(user!.email ?? '[no email]'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: const Text('Liked stories'),
              trailing: Chip(
                label: likes == null
                    ? const CircularProgressIndicator()
                    : Text(likes.toString()),
              ),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      leading: const RoundedBackButton(),
                      title: const Text('Liked Stories'),
                    ),
                    body: PagingList<LikeItem>(
                      onRequest: getStories,
                      builder: (context, item, index) {
                        return StoryTile(
                          item.value,
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryScreen(item.value),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // StoryList(stories)
          ]
        ],
      ),
    );
  }

  Future<List<LikeItem>> getStories(int page, LikeItem? last) async {
    var query = FirebaseFirestore.instance
        .collection('users/${user!.uid}/likes')
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
}
