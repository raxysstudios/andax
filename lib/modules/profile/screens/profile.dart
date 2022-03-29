import 'package:andax/models/story.dart';
import 'package:andax/modules/home/utils/sheets.dart';
import 'package:andax/modules/home/widgets/story_tile.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_stats.dart';

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
    Future.wait([
      updateLikes(user).then(
        (r) => setState(() {
          likes = r;
        }),
      ),
      updateStories(user).then(
        (r) => setState(() {
          stories = r;
        }),
      ),
      updateTranslations(user).then(
        (r) => setState(() {
          translations = r;
        }),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.photoURL == null ? null : NetworkImage(user.photoURL!),
              backgroundColor: Colors.transparent,
            ),
            title: Text(user.displayName ?? '[no name]'),
            subtitle: Text(user.email ?? '[no email]'),
          ),
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
                    onRequest: (i, s) => getLikes(user, i, s),
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
            (i, s) => getStories(user, i, s),
          ),
          buildStoriesTile(
            Icons.translate_rounded,
            'Created translations',
            translations,
            (i, s) => getTranslations(user, i, s),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
