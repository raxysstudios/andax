import 'dart:io';

import 'package:andax/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

enum Availability { loading, available, unavailable }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? get user => FirebaseAuth.instance.currentUser;
  final InAppReview _inAppReview = InAppReview.instance;
  Availability _availability = Availability.loading;

  @override
    void initState() {
      super.initState();

      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        try {
          final isAvailable = await _inAppReview.isAvailable();

          setState(() {
            // This plugin cannot be tested on Android by installing your app
            // locally. See https://github.com/britannio/in_app_review#testing for
            // more information.
            _availability = isAvailable && !Platform.isAndroid
                ? Availability.available
                : Availability.unavailable;
          });
        } catch (e) {
          setState(() => _availability = Availability.unavailable);
        }
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          if (FirebaseAuth.instance.currentUser == null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await showLoadingDialog(context, signIn());
                  setState(() {});
                },
                icon: const Icon(Icons.person_outlined),
                label: Text(
                  user?.displayName ?? 'Sign In',
                ),
              ),
            )
          else ...[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
              ),
              title: Text(user!.displayName ?? 'No Name'),
              trailing: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                },
                icon: const Icon(Icons.logout_outlined),
                tooltip: "Log out",
              ),
            ),
            const Center(
                child: Text(
              "contact developer",
              style: TextStyle(fontSize: 23),
            )),
            ListTile(
              leading: ElevatedButton(
                onPressed: () =>
                    launch("https://wa.me/${"+79871852923"}?text=Hello"),
                child: const Text('Open WhatsApp'),
              ),
              trailing: ElevatedButton(
                onPressed: () => launch("https://t.me/taasneemtoolba"),
                child: const Text('Open Telegram'),
              ),
            ),
            ListTile(
              leading: TextButton.icon(
                icon: const Icon(Icons.star),
                label: const Text('Rate us'),
                onPressed: _requestReview,

              )
            )
          ],
        ],
      ),
    );
  }

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
  Future<void> _requestReview() async{
    if (await _inAppReview.isAvailable()) {
    return await _inAppReview.requestReview();
    }
  }
  // => _inAppReview.requestReview();

}
