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

  List<ThemeData> getThemes(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    );
    const cardTheme = CardTheme(
      clipBehavior: Clip.antiAlias,
    );
    const dividerTheme = DividerThemeData(space: 0);
    return [
      ThemeData().copyWith(
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.grey,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        cardTheme: cardTheme,
        toggleableActiveColor: colorScheme.primary,
        floatingActionButtonTheme: floatingActionButtonTheme,
        dividerTheme: dividerTheme,
      ),
      ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        cardTheme: cardTheme,
        toggleableActiveColor: colorScheme.primary,
        floatingActionButtonTheme: floatingActionButtonTheme,
        dividerTheme: dividerTheme,
      ),
    ];
  }

  @override
  Widget build(context) {
    final themes = getThemes(context);
    return MaterialApp(
      title: 'Andax',
      theme: themes[0],
      darkTheme: themes[1],
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
