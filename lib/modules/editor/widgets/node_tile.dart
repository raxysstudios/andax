import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/shared/widgets/span_icon.dart';
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
      subtitle: node == null
          ? null
          : Row(
              children: [
                if (editor.story.startNodeId == node!.id)
                  const SpanIcon(
                    Icons.login_rounded,
                    padding: EdgeInsets.only(right: 8),
                  ),
                if (node?.image != null)
                  const SpanIcon(
                    Icons.image_rounded,
                    padding: EdgeInsets.only(right: 8),
                  ),
                if (actor != null) ...[
                  SpanIcon(
                    actor.type == ActorType.npc
                        ? Icons.smart_toy_rounded
                        : Icons.face_rounded,
                    padding: const EdgeInsets.only(right: 4),
                  ),
                  Text(
                    editor.tr.actor(actor),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ],
            ),
      trailing: Text(
        '#${getIndex(editor) + 1}',
        style: Theme.of(context).textTheme.subtitle2,
      ),
      selected: selected,
    );
  }
}
