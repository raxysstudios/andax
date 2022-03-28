import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/story.dart';

class NodeTile extends StatelessWidget {
  const NodeTile(
    this.node, {
    this.onTap,
    this.index,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  final Node? node;
  final VoidCallback? onTap;
  final int? index;
  final bool selected;

  int getIndex(StoryEditorState editor) {
    if (index != null) {
      return index!;
    }
    return editor.story.nodes.values.toList().indexOf(node!);
  }

  @override
  Widget build(BuildContext context) {
    if (node == null) {
      return const ListTile(
        title: Text('[MISSING NODE]'),
      );
    }
    final editor = context.watch<StoryEditorState>();
    final actor = editor.story.actors[node!.actorId];
    return ListTile(
      onTap: onTap,
      title: Text(editor.tr.node(node)),
      subtitle: editor.story.startNodeId == node!.id || actor != null
          ? Row(
              children: [
                if (editor.story.startNodeId == node!.id)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
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
                    editor.tr.actor(actor),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ],
            )
          : null,
      trailing: Text(
        '#${getIndex(editor) + 1}',
        style: Theme.of(context).textTheme.subtitle2,
      ),
      selected: selected,
    );
  }
}
