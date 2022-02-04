import 'package:andax/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart' as flutterfire_auth;

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In or Register')),
      body: flutterfire_auth.SignInScreen(
        providerConfigs: [
          const flutterfire_auth.EmailProviderConfiguration(),
          flutterfire_auth.GoogleProviderConfiguration(
              clientId: DefaultFirebaseOptions.currentPlatform.appId),
          const flutterfire_auth.AppleProviderConfiguration(),
        ],
      ),
    );
  }
}
