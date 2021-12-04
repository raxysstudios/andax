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
  Widget buildNotificaion(String text) {
    return Column(
      children: [
        const Divider(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Divider(height: 16),
      ],
    );
  }

  Widget buildMessage(
    String text,
    Actor actor,
    bool isPlayer,
  ) {
    return Card(
      margin: isPlayer
          ? const EdgeInsets.fromLTRB(48, 8, 0, 8)
          : const EdgeInsets.fromLTRB(0, 8, 48, 8),
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
      color: isPlayer ? Theme.of(context).backgroundColor : null,
      child: Padding(
        padding: isPlayer
            ? const EdgeInsets.fromLTRB(8, 8, 20, 8)
            : const EdgeInsets.fromLTRB(20, 8, 8, 8),
        child: Column(
          crossAxisAlignment:
              isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isPlayer && actor.id != widget.previousNode?.actorId)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  getTranslation<ActorTranslation>(
                    widget.translations,
                    actor.id,
                    (t) => t.name,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
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

  @override
  Widget build(BuildContext context) {
    final actor = widget.actors[widget.node.actorId];
    final text = getTranslation<MessageTranslation>(
      widget.translations,
      widget.node.id,
      (t) => t.text,
    );
    if (text.isEmpty) return const SizedBox();
    if (actor == null) return buildNotificaion(text);
    return buildMessage(
      text,
      actor,
      actor.type == ActorType.player,
    );
  }
}
