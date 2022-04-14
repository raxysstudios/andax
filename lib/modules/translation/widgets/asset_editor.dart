import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/translation_editor.dart';

Future<String?> showAssetEditor(
  BuildContext context, {
  required String id,
  required Map<String, String> pending,
}) {
  final editor = context.read<TranslationEditorState>();
  MapEntry<String, String>? asset = editor.changes[id];

  return showEditorSheet<String>(
    context: context,
    title: 'Select asset',
    initial: id,
    onSave: () {
      editor.changes[id] = asset;
      return id;
    },
    builder: (context, setState) {
      void pickPending(MapEntry<String, String>? a) {
        if (a != null) {
          setState(() => asset = a);
        }
      }

      return [
        ListTile(
          title: Text(editor.b[id] ?? ''),
        ),
        buildExplanationTile(context, 'Current translation'),
        RadioListTile<MapEntry<String, String>?>(
          value: null,
          groupValue: asset,
          onChanged: pickPending,
          title: Text(editor.t[id] ?? ''),
        ),
        buildExplanationTile(context, 'Pending translations'),
        for (final a in pending.entries)
          RadioListTile<MapEntry<String, String>>(
            value: a,
            groupValue: asset,
            onChanged: pickPending,
            title: Text(a.value),
          ),
      ];
    },
  );
}
