import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';

Future<MapEntry<String, String>?> showTranslationCreator(BuildContext context) {
  var language = '';
  var title = '';
  return showEditorSheet<MapEntry<String, String>>(
    context: context,
    title: 'Create translation',
    onSave: () => MapEntry(language, title),
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
