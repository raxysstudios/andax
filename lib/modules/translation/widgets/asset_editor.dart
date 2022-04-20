import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/modules/translation/services/assets.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/translation_editor.dart';

Future<void> showAssetEditor(
  BuildContext context, {
  required String id,
  required List<AssetOverwrite> pending,
  IconData? icon,
}) {
  final editor = context.read<TranslationEditorState>();
  var asset = editor.changes[id];
  if (asset != null) {
    asset = pending.firstWhere(
      (e) => e.key == asset?.key && e.value == asset?.value,
      orElse: () => asset!,
    );
  }

  var newTranslation = '';
  return showEditorSheet<void>(
    context: context,
    title: 'Pick translation',
    builder: (context, setState) {
      void pickPending(AssetOverwrite? a) => setState(() {
            asset = a;
            if (asset == null) {
              editor.changes.remove(id);
            } else {
              editor.changes[id] = asset!;
            }
          });

      return [
        ListTile(
          leading: icon == null ? null : Icon(icon),
          title: Text(editor.base[id] ?? ''),
        ),
        buildExplanationTile(context, 'Accepted translation'),
        RadioListTile<AssetOverwrite?>(
          value: null,
          groupValue: asset,
          onChanged: pickPending,
          title: Text(editor.target[id] ?? ''),
        ),
        buildExplanationTile(context, 'Suggest translation'),
        ListTile(
          title: TextFormField(
            maxLines: null,
            onChanged: (s) => newTranslation = s.trim(),
          ),
          trailing: IconButton(
            onPressed: () async {
              if (newTranslation.isNotEmpty) {
                final asset = await showLoadingDialog(
                  context,
                  addPendingAsset(
                    editor.info,
                    id,
                    newTranslation,
                  ),
                );
                pickPending(asset);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add_circle_rounded),
          ),
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
