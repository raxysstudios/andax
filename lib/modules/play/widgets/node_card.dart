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
    final theme = Theme.of(context);
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
        if (node.image != null)
          Image.network(
            node.image!.url,
            height: node.image!.height,
            fit: node.image!.fit,
            alignment: node.image!.alignment,
          ),
        if (actor != null && !thread)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Chip(
                avatar: actor.avatarUrl == null
                    ? null
                    : CircleAvatar(
                        foregroundImage: NetworkImage(actor.avatarUrl!),
                        backgroundColor: Colors.transparent,
                      ),
                label: Text(
                  play.tr.actor(actor),
                ),
                labelStyle: TextStyle(
                  color: isPlayer ? theme.colorScheme.primary : null,
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        if (text.isNotEmpty)
          Card(
            elevation: .5,
            shape: const RoundedRectangleBorder(),
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {},
              child: Padding(
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
            ),
          ),
      ],
    );
  }
}
