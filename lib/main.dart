import 'package:andax/config/auth_providers.dart';
import 'package:andax/config/themes.dart';
import 'package:andax/firebase_options.dart';
import 'package:andax/modules/home/screens/home.dart';
import 'package:andax/store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'modules/home/screens/onboarding.dart';
import 'modules/home/screens/splash.dart';
import 'modules/home/utils/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterFireUIAuth.configureProviders(providerConfigs);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themes = Themes(colorScheme);
    return MaterialApp(
      title: 'Andax',
      theme: themes.light,
      darkTheme: themes.dark,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        title: 'ÆNDAX',
        future: initStore(),
        onLoaded: (context) async {
          final onboarding = await checkOnboarding();
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute(
              builder: (context) => onboarding == null
                  ? const HomeScreen()
                  : OnboardingScreen(onboarding),
            ),
          );
        },
      ),
    );
  }
}
