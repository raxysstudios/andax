import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loading = false;
  List<String> editable = [];

  Future<void> signIn() async {
    setState(() {
      loading = true;
    });
    await FirebaseAuth.instance.signOut();

    final user = await GoogleSignIn().signIn();
    if (user != null) {
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Editors'),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          // Card(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.all(8),
          //         child: ElevatedButton.icon(
          //           onPressed: loading ? null : signIn,
          //           icon: Icon(Icons.person_outlined),
          //           label: Text(
          //             GlobalStore.email ?? 'Sign In',
          //           ),
          //         ),
          //       ),
          //       if (GlobalStore.email == null)
          //         Padding(
          //           padding: const EdgeInsets.only(bottom: 16),
          //           child: Text(
          //             'Sign in with Google to see your options.',
          //             textAlign: TextAlign.center,
          //           ),
          //         )
          //       else ...[
          //         Text(
          //           'With any question regarding the language materials, contact the corresponding editors below.',
          //           textAlign: TextAlign.center,
          //         ),
          //         SizedBox(height: 8),
          //         RichText(
          //           textAlign: TextAlign.center,
          //           text: TextSpan(
          //             style: Theme.of(context).textTheme.bodyText2,
          //             children: [
          //               TextSpan(text: 'You can edit '),
          //               TextSpan(
          //                 text: capitalize(editable.join(', ')),
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //               TextSpan(text: ' yourself.'),
          //             ],
          //           ),
          //         ),
          //         SizedBox(height: 16),
          //       ],
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
