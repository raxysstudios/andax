import 'dart:async';
import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/play/utils/alert.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/widgets/game_results_dialog.dart';
import 'package:andax/modules/play/widgets/transitions_chips.dart';
import 'package:andax/modules/play/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

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
  PlayScreenState createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> {
  Map<String, TranslationAsset> get translations => widget.translation.assets;
  Map<String, Node> get nodes => widget.story.nodes;
  Map<String, Actor> get actors => widget.story.actors;

  late Map<String, Cell> cells = {
    for (final c in widget.story.cells.entries)
      c.key: Cell.fromJson(c.value.toJson())
  };
  final List<Node> storyline = [];

  Timer autoAdvance = Timer(Duration.zero, () {});
  bool get finished =>
      storyline.last.transitions.isEmpty && !autoAdvance.isActive;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    autoAdvance.cancel();
    storyline.clear();
    for (final cell in cells.values) {
      cell.reset();
    }
    advanceNode(
      widget.story.startNodeId?.isEmpty ?? true
          ? nodes.values.first
          : nodes[widget.story.startNodeId]!,
    );
  }

  void advanceNode(Node node) {
    storyline.add(node);
    for (final write in node.cellWrites) {
      cells[write.targetCellId]?.apply(write);
    }

    setState(() {});
    autoAdvance.cancel();

    final transitions = node.transitions;
    if (transitions.isEmpty ||
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Provider.value(
      value: this,
      child: Builder(builder: (context) {
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
                  child: const Icon(Icons.replay_rounded),
                  label: 'Restart',
                  onTap: () => showProgressAlert(context, reset),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.close_rounded),
                  label: 'Exit',
                  onTap: () => showProgressAlert(
                    context,
                    () => Navigator.pop(context),
                  ),
                ),
                if (finished)
                  SpeedDialChild(
                    child: const Icon(Icons.query_stats_rounded),
                    label: 'Results',
                    onTap: () => showGameResultsDialog(context),
                  ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 98),
            children: [
              for (var i = 0; i < storyline.length - 1; i++)
                NodeCard(
                  node: storyline[i],
                  previousNode: i > 0 ? storyline[i - 1] : null,
                  translations: translations,
                  actors: actors,
                ),
              slideUp(
                NodeCard(
                  node: storyline.last,
                  previousNode: storyline.length > 1
                      ? storyline[storyline.length - 2]
                      : null,
                  translations: translations,
                  actors: actors,
                ),
              ),
              if (!autoAdvance.isActive &&
                  storyline.last.transitions.isNotEmpty &&
                  storyline.last.transitionInputSource ==
                      TransitionInputSource.select)
                slideUp(
                  TransitionsChips(
                    transitions: storyline.last.transitions,
                    onTap: (t) => scheduleAvdancement(nodes[t.targetNodeId]!),
                  ),
                ),
              if (autoAdvance.isActive) const TypingIndicator(),
              if (finished)
                slideUp(
                  Column(
                    children: [
                      const Divider(height: 32),
                      Text(
                        'End',
                        style: theme.textTheme.headline6,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
