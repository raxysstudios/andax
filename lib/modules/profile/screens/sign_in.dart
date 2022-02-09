import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart' as flutterfire_auth;

import '../config/auth_providers.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In or Register')),
      body: flutterfire_auth.SignInScreen(
        providerConfigs: providerConfigs,
      ),
    );
  }
}
