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
        if (thread)
          const SizedBox(height: 2)
        else if (actor == null)
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
        Card(
          elevation: .5,
          shape: const RoundedRectangleBorder(),
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (node.image != null)
                  Image.network(
                    node.image!.url,
                    height: node.image!.height,
                    fit: node.image!.fit,
                    alignment: node.image!.alignment,
                  ),
                if (actor != null && !thread)
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(16, 8, 16, text.isEmpty ? 8 : 0),
                    child: Text(
                      play.tr.actor(actor),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isPlayer
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                if (text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: MarkdownBody(
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
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
