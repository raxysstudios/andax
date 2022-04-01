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
    null: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ActorType.player: EdgeInsets.fromLTRB(96, 2, 8, 2),
    ActorType.npc: EdgeInsets.fromLTRB(8, 2, 96, 2),
  };

  static final Map<ActorType?, BorderRadius> _messageBorderRadius = {
    null: BorderRadius.circular(4),
    ActorType.player: const BorderRadius.horizontal(
      left: Radius.circular(16),
      right: Radius.circular(4),
    ),
    ActorType.npc: const BorderRadius.horizontal(
      left: Radius.circular(4),
      right: Radius.circular(16),
    )
  };

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    final actor = play.actors[node.actorId];
    final text = play.tr.node(node, true);
    if (text.isEmpty) return const SizedBox();

    final thread = actor?.id == previousNode?.actorId;
    final isPlayer = actor?.type == ActorType.player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!thread)
          if (actor == null)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '• • •',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              borderRadius: _messageBorderRadius[actor?.type],
              color: Theme.of(context).colorScheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            margin: _messagePadding[actor?.type]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (node.image != null)
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(node.image!.url),
                        fit: node.image!.fit,
                        alignment: isPlayer
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      maxHeight: 224,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: isPlayer
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (actor != null && !thread)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            play.tr.actor(actor),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (text.isNotEmpty)
                        MarkdownBody(
                          data: text,
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
            ),
          ),
        ),
      ],
    );
  }
}
