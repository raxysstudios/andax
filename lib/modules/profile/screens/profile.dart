import 'package:andax/models/story.dart';
import 'package:andax/modules/profile/services/sheets.dart';
import 'package:andax/shared/widgets/column_card.dart';
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
          ColumnCard(
            title: 'Library',
            divider: null,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_rounded),
                title: const Text('Liked stories'),
                trailing: loadingChip(likes),
                onTap: () => showLikedStories(context, user),
              ),
              ListTile(
                leading: const Icon(Icons.history_edu_rounded),
                title: const Text('Created stories'),
                trailing: loadingChip(stories),
                onTap: () => showGenericStoriesList(
                  context,
                  'Created stories',
                  (i, s) => getStories(user, i, s),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: const Text('Created translations'),
                trailing: loadingChip(translations),
                onTap: () => showGenericStoriesList(
                  context,
                  'Created translations',
                  (i, s) => getTranslations(user, i, s),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
