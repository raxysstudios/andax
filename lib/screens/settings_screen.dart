import 'package:andax/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          else
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
              ),
              title: Text(user!.displayName ?? 'Noname'),
              trailing: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                },
                icon: const Icon(Icons.logout_outlined),
                tooltip: 'Log out',
              ),
            )
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
}
