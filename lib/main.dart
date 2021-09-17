import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

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
        accentColor: Colors.grey,
        toggleableActiveColor: theme.colorScheme.primary,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
        floatingActionButtonTheme: floatingActionButtonTheme,
        cardTheme: cardTheme,
      ),
      ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.grey,
        toggleableActiveColor: theme.colorScheme.primary,
        floatingActionButtonTheme: floatingActionButtonTheme,
        cardTheme: cardTheme,
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
              return HomeScreen();
            return Center(
              child: Text('Loading...'),
            );
          }),
    );
  }
}
