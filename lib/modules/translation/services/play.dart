import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:flutter/material.dart';

import '../screens/translations.dart';

void playTranslation(
  BuildContext context,
  Story story,
  Translation targetTranslation,
  Map<String, AssetOverwrite> translationChanges,
) {
  final translation = Translation(
    assets: Map.from(targetTranslation.assets),
  );
  for (final change in translationChanges.entries) {
    translation[change.key] = change.value.value;
  }
  Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return PlayScreen(
          story: story,
          translation: translation,
        );
      },
    ),
  );
}
