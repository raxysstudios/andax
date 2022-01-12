import 'package:andax/widgets/loading_dialog.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              if (user == null) {
                await showLoadingDialog(context, signIn());
              } else {
                await FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(
              user == null ? Icons.login_rounded : Icons.logout_outlined,
            ),
            tooltip: 'Log out',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        children: [
          if (user == null)
            const Center(
              child: Text(
                'No account. Please, sign in above.',
              ),
            )
          else ...[
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
                label: Text(
                  12.toString(),
                ),
              ),
            ),
            // StoryList(stories)
          ]
        ],
      ),
    );
  }

  //   Future<List<StoryInfo>> refreshStories() async {
  //   return await algolia.instance
  //       .index('stories')
  //       .query('')
  //       // .filters('language:${settings.targetLanguage}')
  //       .getObjects()
  //       .then(
  //         (s) => s.hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList(),
  //       );
  // }

  Future<void> signIn() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    final user = await GoogleSignIn().signIn();
    if (user != null) {
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
    }
  }
}
