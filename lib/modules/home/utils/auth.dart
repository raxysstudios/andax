import 'package:andax/modules/profile/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> ensureSignIn(
  BuildContext context,
  VoidCallback onSigned, [
  String title = 'Sign in to continue',
]) async {
  if (FirebaseAuth.instance.currentUser == null) {
    final agree = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign in'),
            ),
          ],
        );
      },
    );
    if (agree ?? false) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(
            popAfterLogin: true,
          ),
        ),
      );
    }
  }
  if (FirebaseAuth.instance.currentUser != null) onSigned();
}
