import 'package:algolia/algolia.dart';
import 'package:andax/test_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

late final algolia;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future firebase = Firebase.initializeApp().then((_) {
    algolia = Algolia.init(
      applicationId: '4NXJPAZXKE',
      apiKey: 'aef86c663aa0f382553f4375013c2de2',
    );
  });

  List<ThemeData> getThemes(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
    final cardTheme = const CardTheme(
      clipBehavior: Clip.antiAlias,
    );
    return [
      ThemeData(
        primaryColor: Colors.white,
        toggleableActiveColor: theme.colorScheme.primary,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
        floatingActionButtonTheme: floatingActionButtonTheme,
        cardTheme: cardTheme,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.grey),
      ),
      ThemeData(
        brightness: Brightness.dark,
        toggleableActiveColor: theme.colorScheme.primary,
        floatingActionButtonTheme: floatingActionButtonTheme,
        cardTheme: cardTheme,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.grey),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themes = getThemes(context);
    return MaterialApp(
      title: 'Andax',
      theme: themes[0],
      darkTheme: themes[1],
      home: FutureBuilder(
          // Initialize FlutterFire:
          future: firebase,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              // return HomeScreen();
              return TestScreen();
            return Center(
              child: Text('Loading...'),
            );
          }),
    );
  }
}
