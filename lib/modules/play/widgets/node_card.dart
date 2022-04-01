import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';

class NodeCard extends StatelessWidget {
  const NodeCard({
    Key? key,
    required this.node,
    required this.previousNode,
  }) : super(key: key);

  final Node node;
  final Node? previousNode;

  static const Map<ActorType?, EdgeInsets> _messagePadding = {
    null: EdgeInsets.symmetric(horizontal: 16),
    ActorType.player: EdgeInsets.only(left: 96, right: 16),
    ActorType.npc: EdgeInsets.only(left: 16, right: 96)
  };

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    final actor = play.actors[node.actorId];
    final text = play.tr.node(node);
    if (text.isEmpty) return const SizedBox();

    final thread = actor?.id == previousNode?.actorId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actor == null && !thread) ...[
          const SizedBox(height: 16),
          const Text(
            '• • •',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        Padding(
          padding: _messagePadding[actor?.type] ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: actor?.type == ActorType.player
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (actor != null && !thread)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    play.tr.actor(actor),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 16,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
