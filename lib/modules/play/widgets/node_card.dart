import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../utils/get_translation.dart';

class NodeCard extends StatefulWidget {
  final Node node;
  final Node? previousNode;
  final Map<String, TranslationAsset> translations;
  final Map<String, Actor> actors;

  const NodeCard({
    Key? key,
    required this.node,
    required this.previousNode,
    required this.translations,
    required this.actors,
  }) : super(key: key);

  @override
  _NodeCardState createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  @override
  Widget build(BuildContext context) {
    final actor = widget.actors[widget.node.actorId];
    final text = getTranslation<MessageTranslation>(
      widget.translations,
      widget.node.id,
      (t) => t.text,
    );
    if (text.isEmpty) return const SizedBox();
    if (actor == null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final thread = actor.id == widget.previousNode?.actorId;
    final isPlayer = actor.type == ActorType.player;
    return Card(
      elevation: .5,
      margin: isPlayer
          ? EdgeInsets.fromLTRB(48, thread ? 4 : 16, 0, 0)
          : EdgeInsets.fromLTRB(0, thread ? 4 : 16, 48, 0),
      shape: isPlayer
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(4),
              ),
            )
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
      child: Padding(
        padding: isPlayer
            ? const EdgeInsets.fromLTRB(8, 8, 20, 8)
            : const EdgeInsets.fromLTRB(20, 8, 8, 8),
        child: Column(
          crossAxisAlignment:
              isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!thread)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  getTranslation<ActorTranslation>(
                    widget.translations,
                    actor.id,
                    (t) => t.name,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color:
                        isPlayer ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ),
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
    );
  }
}
