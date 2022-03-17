import 'dart:async';
import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/play/widgets/cells_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

import '../utils/get_translation.dart';
import '../widgets/node_card.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    required this.story,
    required this.translation,
    Key? key,
  }) : super(key: key);

  final Story story;
  final Translation translation;

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Map<String, TranslationAsset> get translations => widget.translation.assets;
  Map<String, Node> get nodes => widget.story.nodes;
  Map<String, Actor> get actors => widget.story.actors;
  Map<String, Cell> get cells => widget.story.cells;

  final List<Node> storyline = [];

  Timer? autoAdvance;

  @override
  void initState() {
    super.initState();
    advanceNode(widget.story.startNodeId?.isEmpty ?? true
        ? nodes.values.first
        : nodes[widget.story.startNodeId]!);
  }

  void advanceNode(Node node) {
    storyline.add(node);
    if (node.cellWrites != null) {
      for (final write in node.cellWrites!.entries) {
        cells[write.key]!.value = write.value;
      }
    }
    setState(() {});
    autoAdvance?.cancel();

    if (node.transitions == null ||
        node.transitionInputSource == TransitionInputSource.select) return;

    autoAdvance = Timer(
      const Duration(milliseconds: 500),
      () {
        final transitions = node.transitions!;
        if (node.transitionInputSource == TransitionInputSource.random) {
          final index = Random().nextInt(transitions.length);
          advanceNode(nodes[transitions[index].targetNodeId]!);
        } else {
          // for (final transition in transitions) {
          //   final transition.text
          // }
        }
      },
    );
  }

  Widget animateMessage(Widget child) {
    return PlayAnimation<double>(
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeInOutQuad,
      duration: const Duration(milliseconds: 200),
      child: child,
      builder: (context, child, tween) {
        return Opacity(
          opacity: tween,
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - tween)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: Text(StoryTranslation.get(widget.translation)!.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          for (var i = 0; i < storyline.length - 1; i++)
            NodeCard(
              node: storyline[i],
              previousNode: i > 0 ? storyline[i - 1] : null,
              translations: translations,
              actors: actors,
            ),
          animateMessage(NodeCard(
            node: storyline.last,
            previousNode:
                storyline.length > 1 ? storyline[storyline.length - 2] : null,
            translations: translations,
            actors: actors,
          )),
          if (storyline.last.transitions != null &&
              storyline.last.transitionInputSource ==
                  TransitionInputSource.select)
            animateMessage(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final transition in storyline.last.transitions!)
                    InputChip(
                      onPressed: () =>
                          advanceNode(nodes[transition.targetNodeId]!),
                      label: Text(
                        getTranslation<MessageTranslation>(
                          translations,
                          transition.id,
                          (t) => t.text,
                        ),
                      ),
                    ),
                ],
              ),
            )),
          if (storyline.last.transitions == null)
            animateMessage(
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'End',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 32,
                    ),
                    child: CellsList(
                      cells: cells.values.toList(),
                      translation: widget.translation,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
