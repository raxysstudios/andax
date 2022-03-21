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

  final Cell? cell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: cell == null
          ? null
          : Icon(
              cell!.display == null
                  ? Icons.visibility_off_rounded
                  : cell!.display == CellDisplay.check
                      ? Icons.check_circle_rounded
                      : cell!.display == CellDisplay.text
                          ? Icons.short_text_rounded
                          : Icons.linear_scale_rounded,
            ),
      title: Text(
        cell == null
            ? '[NO CELL]'
            : MessageTranslation.getText(
                context.watch<StoryEditorState>().translation,
                cell!.id,
              ),
      ),
      trailing: cell?.max == null
          ? null
          : Text(
              '/ ${cell!.max}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
      onTap: onTap,
    );
  }
}
