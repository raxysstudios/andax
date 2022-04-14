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
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:provider/provider.dart';

import '../widgets/node_display.dart';

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
  Node? _pending;
  final _scroll = ScrollController();
  final audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
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
    final audioUrl = tr.audio(node) ?? '';
    if (audioUrl.isNotEmpty) {
      if (audioPlayer.state == PlayerState.PLAYING) {
        audioPlayer.stop();
      }
      audioPlayer.play(audioUrl);
    }
    setState(() {});
    cells['node']?.value = '';

    if (node.input == NodeInputType.select || node.transitions.isEmpty) return;
    if (node.input == NodeInputType.random) {
      cells['node']?.value =
          Random().nextInt(node.transitions.length).toString();
    }
    attemptMove();
  }

  void attemptMove() {
    final last = storyline.last;
    for (final transition in last.transitions) {
      if (transition.condition.check(cells)) {
        final node = nodes[transition.targetNodeId];
        if (node != null) {
          setState(() {
            _pending = node;
            _timer = PausableTimer(
              Duration(
                milliseconds: 1000 + 50 * tr.node(last).length,
              ),
              acceptPending,
            )..start();
          });
          return;
        }
      }
    }
  }

  void acceptPending() {
    final node = _pending;
    if (node == null) return;
    _timer.cancel();
    _pending = null;
    moveAt(node);
    SchedulerBinding.instance?.addPostFrameCallback(
      (_) => _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  void openMenu(BuildContext context) async {
    _timer.pause();
    await showPlayMenu(context);
    _timer.start();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      builder: (context, _) {
        return WillPopScope(
          onWillPop: () {
            openMenu(context);
            return Future.value(false);
          },
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FloatingActionButton.small(
                child: const Icon(Icons.menu_rounded),
                onPressed: () => openMenu(context),
              ),
            ),
            body: ListView(
              controller: _scroll,
              padding: const EdgeInsets.only(top: 76, bottom: 32),
              children: [
                for (var i = 0; i < storyline.length - 1; i++)
                  NodeDisplay(
                    node: storyline[i],
                    previousNode: i > 0 ? storyline[i - 1] : null,
                  ),
                slideUp(
                  key: Key(storyline.last.id),
                  child: NodeDisplay(
                    node: storyline.last,
                    previousNode: storyline.length > 1
                        ? storyline[storyline.length - 2]
                        : null,
                  ),
                ),
                if (_timer.isActive)
                  slideUp(
                    key: Key('${_pending?.id}_tp'),
                    child: TypingIndicator(onTap: acceptPending),
                  )
                else if (storyline.last.input == NodeInputType.select)
                  slideUp(
                    key: Key('${storyline.last.id}_tr'),
                    child: TransitionsChips(
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
                    key: const Key('end'),
                    child: Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Icon(Icons.done_all_rounded),
                        ),
                        GameResults(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
