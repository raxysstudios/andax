import 'dart:async';

import 'package:andax/models/story.dart';
import 'package:andax/modules/profile/services/sheets.dart';
import 'package:andax/shared/widgets/column_card.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/display_name.dart';
import '../services/user_stats.dart';

typedef LikeItem = MapEntry<DocumentSnapshot, StoryInfo>;

class ProfileScreen extends StatefulWidget {
  final User _user;

  const ProfileScreen(this._user, {Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  int? likes;
  int? stories;
  int? translations;
  late StreamSubscription<User?> _userSubscription;

  @override
  void initState() {
    super.initState();
    user = widget._user;
    _userSubscription = FirebaseAuth.instance.userChanges().listen((newUser) {
      setState(() {
        if (newUser != null) {
          user = newUser;
        }
      });
    });
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

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  Widget loadingChip(int? value) => value == null
      ? const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(),
        )
      : Chip(
          label: Text(value.toString()),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Profile'),
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
            trailing: const Icon(Icons.edit_rounded),
            onTap: () async {
              final name = await promptDisplayNameChange(context, user);
              if (name != null && mounted) {
                await showLoadingDialog(
                  context,
                  user.updateDisplayName(name),
                );
              }
            },
          ),
          ColumnCard(
            title: 'Library',
            children: [
              ListTile(
                title: const Text('Liked stories'),
                leading: const Icon(Icons.favorite_rounded),
                trailing: loadingChip(likes),
                onTap: () => showLikedStories(context, user),
              ),
              ListTile(
                title: const Text('Your stories'),
                leading: const Icon(Icons.history_edu_rounded),
                trailing: loadingChip(stories),
                onTap: () => showGenericStoriesList(
                  context,
                  'Your stories',
                  (i, s) => getStories(user, page: i, last: s),
                ),
              ),
              ListTile(
                title: const Text('Your translations'),
                leading: const Icon(Icons.translate_rounded),
                trailing: loadingChip(translations),
                onTap: () => showGenericStoriesList(
                  context,
                  'Your translations',
                  (i, s) => getTranslations(user, page: i, last: s),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
