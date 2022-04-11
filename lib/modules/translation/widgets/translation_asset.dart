import 'package:andax/modules/translation/screens/translation_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TranslationAsset extends StatelessWidget {
  const TranslationAsset(
    this.id, {
    this.icon,
    this.maxLines = 1,
    Key? key,
  }) : super(key: key);

  final IconData? icon;
  final int? maxLines;
  final String id;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<TranslationEditorScreenState>();
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: TextFormField(
        maxLines: null,
        decoration: InputDecoration(
          helperText: editor.widget.base[id],
        ),
        initialValue: editor.widget.target[id],
        onChanged: (s) => editor.widget.target[id] = s.trim(),
      ),
    );
  }
}
