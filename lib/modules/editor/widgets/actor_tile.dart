import 'package:andax/models/actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

class ActorTile extends StatelessWidget {
  const ActorTile(
    this.actor, {
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.allowNarrator = false,
    this.index,
    Key? key,
  }) : super(key: key);

  final Actor? actor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool allowNarrator;
  final int? index;

  int? getIndex(StoryEditorState editor) {
    if (index != null) {
      return index;
    }
    if (actor != null) {
      return editor.story.actors.values.toList().indexOf(actor!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final index = getIndex(editor);
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: const Icon(Icons.person_rounded),
      title: Text(
        allowNarrator
            ? editor.tr[actor?.id] ?? 'Narrator'
            : editor.tr.actor(actor),
      ),
      trailing: index == null
          ? null
          : Text(
              '#${index + 1}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
      selected: selected,
    );
  }
}
