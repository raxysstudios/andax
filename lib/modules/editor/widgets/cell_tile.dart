import 'package:andax/models/cell.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/screens/story.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CellTile extends StatelessWidget {
  const CellTile(
    this.cell, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Cell cell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        cell.numeric ? Icons.calculate_rounded : Icons.text_fields_rounded,
      ),
      title: Text(
        MessageTranslation.getText(
          context.watch<StoryEditorState>().translation,
          cell.id,
        ),
      ),
      trailing: cell.numeric
          ? Text(
              '/ ${cell.max}',
              style: Theme.of(context).textTheme.subtitle2,
            )
          : null,
      onTap: onTap,
    );
  }
}
