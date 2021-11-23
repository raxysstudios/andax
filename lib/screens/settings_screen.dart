import 'package:contactus/contactus.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? get user => FirebaseAuth.instance.currentUser;
  double rating = 0;
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
              leading: RaisedButton(
                onPressed: () async =>
                    await launch("https://wa.me/${"+79871852923"}?text=Hello"),
                child: const Text('Open WhatsApp'),
                color: Colors.black,
              ),
              trailing: RaisedButton(
                onPressed: () async =>
                    await launch("https://t.me/taasneemtoolba"),
                child: const Text('Open Telegram'),
                color: Colors.black,

              ),
            ),
            ListTile(
              title: const Text("Rate us"),
              trailing: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                ),
                onRatingUpdate: (rating) {
                  rating = rating;
                },
              ),
            ),
          ],
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
