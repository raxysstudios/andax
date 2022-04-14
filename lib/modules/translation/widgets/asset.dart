import 'package:andax/modules/translation/screens/translation_editor.dart';
import 'package:andax/modules/translation/services/assets.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'asset_editor.dart';

class AssetOverwrite {
  AssetOverwrite(this.id, this.text);

  final String id;
  final String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AssetOverwrite && id == other.id && text == other.text;
  }

  @override
  int get hashCode => '$id $text'.hashCode;
}

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
    final change = editor.changes[id]?.text;
    final base = editor.base[id];
    final target = change ?? editor.target[id];
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: target == null ? null : Text(target),
      subtitle: base == null ? null : Text(base),
      trailing: change == null ? null : const Icon(Icons.edit_rounded),
      onTap: () async {
        final pending = await showLoadingDialog(
          context,
          getPendingAssets(editor.info, id),
        );
        await showAssetEditor(
          context,
          id: id,
          pending: pending ?? [],
        );
        editor.setState(() {});
      },
    );
  }
}
