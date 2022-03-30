import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
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
  Translation get tr => widget.translation;

  late Map<String, Cell> cells = {
    for (final c in widget.story.cells.entries)
      c.key: Cell.fromJson(c.value.toJson()),
    'node': Cell('node'),
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
      cell.value = '';
    }
    moveAt(
      widget.story.startNodeId?.isEmpty ?? true
          ? nodes.values.first
          : nodes[widget.story.startNodeId]!,
    );
  }

  void moveAt(Node node) {
    storyline.add(node);
    for (final write in node.cellWrites) {
      cells[write.targetCellId]?.apply(write);
    }
    setState(() {});
    cells['node']?.value = '';
    _timer.cancel();

    if (node.transitions.isEmpty) {
      PausableTimer(
        const Duration(milliseconds: 500),
        () => showGameResultsDialog(context, this),
      ).start();
      return;
    }
    if (node.input == NodeInputType.select) return;
    if (node.input == NodeInputType.random) {
      cells['node']?.value =
          Random().nextInt(node.transitions.length).toString();
    }
    attemptMove();
  }

  void attemptMove() {
    final transitions = storyline.last.transitions;
    for (final transition in transitions) {
      if (transition.condition.check(cells)) {
        final node = nodes[transition.targetNodeId];
        if (node != null) {
          scheduleMove(node);
          return;
        }
      }
    }
  }

  void scheduleMove(Node node) {
    _timer = PausableTimer(
      Duration(
        milliseconds: max(
          500,
          50 * tr.node(node).length,
        ),
      ),
      () {
        moveAt(node);
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
                onOpen: _timer.pause,
                onClose: _timer.start,
                icon: Icons.menu_rounded,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                spaceBetweenChildren: 9,
                switchLabelPosition: true,
                label: const Text('Menu'),
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
                    storyline.last.input == NodeInputType.select)
                  slideUp(
                    TransitionsChips(
                      transitions: storyline.last.transitions,
                      onTap: (t) {
                        cells['node']?.value =
                            storyline.last.transitions.indexOf(t).toString();
                        attemptMove();
                      },
                    ),
                  ),
                if (_timer.isActive) const TypingIndicator(),
                if (finished)
                  slideUp(
                    Column(
                      children: const [
                        Divider(
                          height: 32,
                          indent: 16,
                          endIndent: 16,
                        ),
                        Icon(Icons.done_all),
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
