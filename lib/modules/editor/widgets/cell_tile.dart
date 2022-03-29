import 'package:andax/models/cell.dart';
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

  static const Map<CellDisplay?, IconData> _displayIcon = {
    null: Icons.visibility_off_rounded,
    CellDisplay.check: Icons.check_circle_rounded,
    CellDisplay.text: Icons.short_text_rounded,
    CellDisplay.range: Icons.linear_scale_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_displayIcon[cell?.display]),
      title: Text(context.watch<StoryEditorState>().tr.cell(cell)),
      trailing: cell?.max == double.infinity
          ? null
          : Text(
              '/ ${cell!.max}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
      onTap: onTap,
    );
  }
}
