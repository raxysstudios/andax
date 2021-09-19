import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NodeCard extends StatefulWidget {
  final Node node;
  final Node? previousNode;
  final Map<String, TranslationAsset> translations;
  final Map<String, Actor> actors;

  NodeCard({
    required this.node,
    required this.previousNode,
    required this.translations,
    required this.actors,
  }) : super(key: ValueKey(node.id));

  @override
  _NodeCardState createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  @override
  Widget build(BuildContext context) {
    final actor = widget.actors[widget.node.actorId];
    final translation = widget.translations[widget.node.id];
    if (translation == null) return SizedBox();

    final isPlayer = actor?.type == ActorType.player;
    final printActor =
        actor != null && actor.id != widget.previousNode?.actorId;

    return Padding(
      padding: isPlayer
          ? const EdgeInsets.only(left: 32)
          : const EdgeInsets.only(right: 32),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment:
                isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (printActor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    getTranslation<ActorTranslation>(
                      widget.translations,
                      actor!.id,
                      (t) => t.name,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              MarkdownBody(
                data: getTranslation<MessageTranslation>(
                  widget.translations,
                  actor!.id,
                  (t) => t.text,
                ),
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
      ),
    );
  }
}
