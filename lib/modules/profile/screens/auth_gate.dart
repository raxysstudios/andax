import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile.dart';
import 'sign_in.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not signed in
          return const SignInScreen();
        }

        final user = snapshot.data!;
        return ProfileScreen(user);
      },
    );
  }
}
