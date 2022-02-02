import 'package:andax/config/themes.dart';
import 'package:andax/screens/home_screen.dart';
import 'package:andax/store.dart';
import 'package:flutter/material.dart';
import 'widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        onLoaded: (context) => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
      ),
    );
  }
}
