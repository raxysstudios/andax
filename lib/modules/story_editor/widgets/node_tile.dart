import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:flutter/material.dart';

class NodeTile extends StatelessWidget {
  const NodeTile(
    this.node,
    this.editor, {
    this.onTap,
    this.index,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  final Node node;
  final StoryEditorState editor;
  final VoidCallback? onTap;
  final int? index;
  final bool selected;

  int getIndex() {
    if (index != null) {
      return index!;
    }
    return editor.story.nodes.values.toList().indexOf(node);
  }

  @override
  Widget build(BuildContext context) {
    final actor = editor.story.actors[node.actorId];
    return ListTile(
      onTap: onTap,
      title: Text(
        MessageTranslation.getText(
          editor.translation,
          node.id,
        ),
      ),
      subtitle: editor.story.startNodeId == node.id || actor != null
          ? null
          : Row(
              children: [
                if (editor.story.startNodeId == node.id)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                  ),
                if (actor != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      actor.type == ActorType.npc
                          ? Icons.smart_toy_rounded
                          : Icons.face_rounded,
                      size: 16,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                  ),
                  Text(
                    ActorTranslation.getName(
                      editor.translation,
                      actor.id,
                    ),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ],
            ),
      trailing: Text(
        '#${getIndex() + 1}',
        style: Theme.of(context).textTheme.subtitle2,
      ),
      selected: selected,
    );
  }
}
