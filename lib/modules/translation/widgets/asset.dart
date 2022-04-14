import 'package:andax/modules/translation/screens/translation_editor.dart';
import 'package:andax/modules/translation/services/assets.dart';
import 'package:andax/modules/translation/services/translations.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'asset_editor.dart';

class Asset extends StatelessWidget {
  const Asset(
    this.id, {
    this.icon,
    Key? key,
  }) : super(key: key);

  final IconData? icon;
  final String id;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<TranslationEditorState>();
    final base = editor.b[id];
    final target = editor.changes[id]?.value ?? editor.t[id];
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: target == null ? null : Text(target),
      subtitle: base == null ? null : Text(base),
      trailing:
          editor.changes[id] == null ? null : const Icon(Icons.edit_rounded),
      onTap: () async {
        final pending = await showLoadingDialog(
          context,
          getPendingAssets(editor.i, id),
        );
        await showAssetEditor(
          context,
          id: id,
          pending: pending ?? {},
        );
      },
    );
  }
}
