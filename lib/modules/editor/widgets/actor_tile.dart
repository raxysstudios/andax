import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

class ActorTile extends StatelessWidget {
  const ActorTile(
    this.actor, {
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.index,
    Key? key,
  }) : super(key: key);

  final Actor? actor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
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
      leading: Icon(
        actor == null
            ? Icons.person_outline_rounded
            : actor!.type == ActorType.npc
                ? Icons.smart_toy_rounded
                : Icons.face_rounded,
      ),
      title: Text(
        actor == null
            ? '<no actor>'
            : ActorTranslation.getName(
                editor.translation,
                actor!.id,
              ),
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
