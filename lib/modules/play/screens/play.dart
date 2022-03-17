import 'dart:async';
import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/play/widgets/cells_list.dart';
import 'package:andax/modules/play/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  Timer autoAdvance = Timer(Duration.zero, () {});

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
        cells[write.key]?.value = write.value;
      }
    }
    setState(() {});
    autoAdvance.cancel();

    final transitions = node.transitions;
    if (transitions == null ||
        node.transitionInputSource == TransitionInputSource.select) return;

    Node? next;
    if (node.transitionInputSource == TransitionInputSource.random) {
      final index = Random().nextInt(transitions.length);
      next = nodes[transitions[index].targetNodeId];
    } else {
      // for (final transition in transitions) {
      //   final transition.text
      // }
    }
    if (next != null) scheduleAvdancement(next);
  }

  void scheduleAvdancement(Node node) {
    final typing = 50 *
        MessageTranslation.getText(
          widget.translation,
          node.id,
        ).length;
    autoAdvance = Timer(
      Duration(milliseconds: max(500, typing)),
      () => advanceNode(node),
    );
    setState(() {});
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
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SpeedDial(
          icon: Icons.pause_rounded,
          activeIcon: Icons.play_arrow_rounded,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          activeBackgroundColor: theme.colorScheme.primary,
          activeForegroundColor: theme.colorScheme.onPrimary,
          spaceBetweenChildren: 9,
          switchLabelPosition: true,
          label: const Text('Pause'),
          activeLabel: const Text('Resume'),
          buttonSize: const Size.square(48),
          spacing: 7,
          direction: SpeedDialDirection.down,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.close_rounded),
              label: 'Exit',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 108),
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
          if (!autoAdvance.isActive &&
              storyline.last.transitions != null &&
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
                          scheduleAvdancement(nodes[transition.targetNodeId]!),
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
          if (autoAdvance.isActive) const TypingIndicator(),
          if (storyline.last.transitions == null)
            animateMessage(
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Text(
                          'End',
                          style: theme.textTheme.headline6,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.done_all_rounded),
                          label: const Text('Finish play'),
                        ),
                      ],
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
