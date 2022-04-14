import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/translation_editor.dart';

Future<String?> showAssetEditor(
  BuildContext context, {
  required String id,
  required List<AssetOverwrite> pending,
}) {
  final editor = context.read<TranslationEditorState>();
  AssetOverwrite? asset = editor.changes[id];
  if (asset != null) {
    asset = pending.firstWhere(
      (e) => e.key == asset?.key && e.value == asset?.value,
      orElse: () => asset!,
    );
  }

  return showEditorSheet<String>(
    context: context,
    title: 'Select asset',
    initial: id,
    onSave: () {
      if (asset == null) {
        editor.changes.remove(id);
      } else {
        editor.changes[id] = asset;
      }
      return id;
    },
    builder: (context, setState) {
      void pickPending(AssetOverwrite? a) => setState(() => asset = a);

      return [
        ListTile(
          title: Text(editor.base[id] ?? ''),
        ),
        buildExplanationTile(context, 'Accepted translation'),
        RadioListTile<AssetOverwrite?>(
          value: null,
          groupValue: asset,
          onChanged: pickPending,
          title: Text(editor.target[id] ?? ''),
        ),
        buildExplanationTile(context, 'Pending translations'),
        for (final a in pending)
          RadioListTile<AssetOverwrite>(
            value: a,
            groupValue: asset,
            onChanged: pickPending,
            title: Text(a.value),
          ),
      ];
    },
  );
}
