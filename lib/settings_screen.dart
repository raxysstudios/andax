import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          if (FirebaseAuth.instance.currentUser == null)
            ElevatedButton.icon(
              onPressed: () async {
                await signIn();
                setState(() {});
              },
              icon: Icon(Icons.person_outlined),
              label: Text(
                user?.displayName ?? 'Sign In',
              ),
            )
          else ...[
            ListTile(
              leading: CircleAvatar(
                child: user?.photoURL != null
                    ? Image.network(user!.photoURL!)
                    : Icon(Icons.account_circle_outlined),
              ),
              title: Text(user!.displayName ?? 'Noname'),
              trailing: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                },
                icon: Icon(Icons.logout_outlined),
                tooltip: "Log out",
              ),
            )
          ],
        ],
      ),
    );
  }

  Future<void> signIn() async {
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
