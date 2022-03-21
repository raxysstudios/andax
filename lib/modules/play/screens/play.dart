import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/play/utils/alert.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/widgets/game_results_dialog.dart';
import 'package:andax/modules/play/widgets/transitions_chips.dart';
import 'package:andax/modules/play/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pausable_timer/pausable_timer.dart';
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
  Map<String, Node> get nodes => widget.story.nodes;
  Map<String, Actor> get actors => widget.story.actors;

  late Map<String, Cell> cells = {
    for (final c in widget.story.cells.entries)
      c.key: Cell.fromJson(c.value.toJson())
  };
  final List<Node> storyline = [];

  bool get finished => storyline.last.transitions.isEmpty && !_timer.isActive;
  var _timer = PausableTimer(Duration.zero, () {});
  final _dial = ValueNotifier(false);
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _dial.addListener(() {
      if (_dial.value) {
        _timer.pause();
      } else {
        _timer.start();
      }
    });
    reset();
  }

  void reset() {
    _timer.cancel();
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
    _timer.cancel();

    final transitions = node.transitions;
    if (transitions.isEmpty) {
      PausableTimer(
        const Duration(milliseconds: 500),
        () => showGameResultsDialog(context, this),
      ).start();
      return;
    }
    if (node.transitionInputSource == TransitionInputSource.select) {
      return;
    }

    final next = makeTransition(node)?.targetNodeId;
    if (nodes[next] != null) scheduleAvdancement(nodes[next]!);
  }

  Transition? makeTransition(Node node) {
    final transitions = node.transitions;
    if (node.transitionInputSource == TransitionInputSource.random) {
      final index = Random().nextInt(transitions.length);
      return transitions[index];
    } else {
      for (final transition in transitions.map((e) => e as CelledTransition)) {
        if (transition.comparision == null) return transition;
        final cell = cells[transition.targetCellId]?.value;
        if (cell == null) continue;
        if (transition.comparision == ComparisionMode.equal) {
          if (cell == transition.value) return transition;
        } else {
          final c = int.tryParse(cell) ?? 0;
          final v = int.tryParse(transition.value) ?? 0;
          if (transition.comparision == ComparisionMode.lesser
              ? c < v
              : c > v) {
            return transition;
          }
        }
      }
    }
    return null;
  }

  void scheduleAvdancement(Node node) {
    final typing = 50 *
        MessageTranslation.getText(
          widget.translation,
          node.id,
        ).length;
    _timer = PausableTimer(
      Duration(milliseconds: max(500, typing)),
      () {
        advanceNode(node);
        SchedulerBinding.instance?.addPostFrameCallback(
          (_) => _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
          ),
        );
      },
    )..start();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Provider.value(
      value: this,
      child: Builder(builder: (context) {
        return WillPopScope(
          onWillPop: () {
            _dial.value = true;
            return Future.value(false);
          },
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SpeedDial(
                openCloseDial: _dial,
                onOpen: () => setState(_timer.pause),
                onClose: () => setState(_timer.start),
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
                      onTap: () => showGameResultsDialog(context, this),
                    ),
                ],
              ),
            ),
            body: ListView(
              controller: _scroll,
              padding: const EdgeInsets.only(top: 98, bottom: 32),
              children: [
                for (var i = 0; i < storyline.length - 1; i++)
                  NodeCard(
                    node: storyline[i],
                    previousNode: i > 0 ? storyline[i - 1] : null,
                  ),
                slideUp(
                  NodeCard(
                    node: storyline.last,
                    previousNode: storyline.length > 1
                        ? storyline[storyline.length - 2]
                        : null,
                  ),
                ),
                if (!_timer.isActive &&
                    storyline.last.transitions.isNotEmpty &&
                    storyline.last.transitionInputSource ==
                        TransitionInputSource.select)
                  slideUp(
                    TransitionsChips(
                      transitions: storyline.last.transitions,
                      onTap: (t) => scheduleAvdancement(nodes[t.targetNodeId]!),
                    ),
                  ),
                if (_timer.isActive) const TypingIndicator(),
                if (finished)
                  slideUp(
                    Column(
                      children: [
                        const Divider(
                          height: 32,
                          indent: 64,
                          endIndent: 64,
                        ),
                        Text(
                          'End',
                          style: theme.textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
