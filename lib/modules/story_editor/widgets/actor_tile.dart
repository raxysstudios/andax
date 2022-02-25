import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:flutter/material.dart';

class ActorTile extends StatelessWidget {
  const ActorTile(
    this.actor,
    this.editor, {
    this.onTap,
    this.selected = false,
    this.index,
    Key? key,
  }) : super(key: key);

  final Actor? actor;
  final StoryEditorState editor;
  final VoidCallback? onTap;
  final bool selected;
  final int? index;

  int? getIndex() {
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
    final index = getIndex();
    return ListTile(
      onTap: onTap,
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
