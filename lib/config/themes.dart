import 'package:flutter/material.dart';
import './themes/light.dart';
import './themes/dark.dart';

class Themes {
  final ThemeData light;
  final ThemeData dark;

  Themes(ColorScheme scheme)
      : light = getLightTheme(scheme),
        dark = getDarkTheme(scheme);
}
