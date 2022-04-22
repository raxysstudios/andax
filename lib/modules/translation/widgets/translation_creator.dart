import 'package:andax/models/story.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';

import '../services/translations.dart';

Future<StoryInfo?> showTranslationCreator(
  BuildContext context,
  StoryInfo base,
) async {
  var language = '';
  var title = '';
  return await showEditorSheet<Future<StoryInfo?>>(
    context: context,
    title: 'Create translation',
    onSave: () => createTranslation(context, base, language, title),
    builder: (context, setState) {
      return [
        ListTile(
          leading: const Icon(Icons.language_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Translation language',
            ),
            autofocus: true,
            validator: emptyValidator,
            onChanged: (s) => language = s.trim(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.title_rounded),
          title: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Translated title',
            ),
            validator: emptyValidator,
            onChanged: (s) => title = s.trim(),
          ),
        ),
      ];
    },
  );
}
