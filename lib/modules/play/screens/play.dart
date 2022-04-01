import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/utils/menu.dart';
import 'package:andax/modules/play/widgets/game_results.dart';
import 'package:andax/modules/play/widgets/transitions_chips.dart';
import 'package:andax/modules/play/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

    if (node.input == NodeInputType.select || node.transitions.isEmpty) return;
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
    return Provider.value(
      value: this,
      builder: (context, _) {
        return WillPopScope(
          onWillPop: () {
            _dial.value = true;
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.menu_rounded),
                label: const Text('Menu'),
                onPressed: () async {
                  _timer.pause();
                  await showPlayMenu(context);
                  _timer.start();
                },
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
                if (_timer.isActive)
                  const TypingIndicator()
                else if (storyline.last.input == NodeInputType.select)
                  slideUp(
                    TransitionsChips(
                      transitions: storyline.last.transitions,
                      onTap: (t) {
                        cells['node']?.value =
                            storyline.last.transitions.indexOf(t).toString();
                        attemptMove();
                      },
                    ),
                  )
                else if (storyline.last.transitions.isEmpty)
                  slideUp(
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          Icon(Icons.done_all_rounded),
                          SizedBox(height: 16),
                          Card(child: GameResults()),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
