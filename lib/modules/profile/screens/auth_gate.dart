import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'profile.dart';
import 'sign_in.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    this.openProfile = true,
    Key? key,
  }) : super(key: key);

  final bool openProfile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not signed in
          return const SignInScreen();
        }
        if (openProfile) return ProfileScreen(snapshot.data!);
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => Navigator.pop(context),
        );
        return const SizedBox();
      },
    );
  }
}
