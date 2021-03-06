import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/utils/audio_controller.dart';
import 'package:andax/modules/play/widgets/game_results.dart';
import 'package:andax/modules/play/widgets/menu_button.dart';
import 'package:andax/modules/play/widgets/transitions_chips.dart';
import 'package:andax/modules/play/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:provider/provider.dart';

import '../utils/alert.dart';
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
  final audio = AudioController();

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
    final aUrl = tr.audio(node);
    if (aUrl.isEmpty) {
      audio.stop();
    } else {
      audio.play(aUrl, node.id);
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
    void launchTimer(int mils) {
      setState(() {
        _timer = PausableTimer(
          Duration(
            milliseconds: 1000 + mils,
          ),
          acceptPending,
        )..start();
      });
    }

    final last = storyline.last;
    for (final transition in last.transitions) {
      if (transition.condition.check(cells)) {
        final node = nodes[transition.targetNodeId];
        setState(() => _pending = node);
        if (node != null) {
          final textDur = last.input == NodeInputType.select
              ? 0
              : 25 * tr.node(last).length;
          if (audio.url.isEmpty) {
            launchTimer(textDur);
          } else {
            audio.player.getDuration().then(
                  (_) => launchTimer(
                    max(audio.duration, textDur),
                  ),
                );
          }
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
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      builder: (context, _) {
        return WillPopScope(
          onWillPop: () {
            _timer.pause();
            showProgressAlert(
              context,
              () => Navigator.pop(context),
            );
            _timer.start();
            return Future.value(false);
          },
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: const Padding(
              padding: EdgeInsets.only(top: 16),
              child: MenuButton(),
            ),
            appBar: AppBar(toolbarHeight: 0),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                          child: Icon(Icons.done_all_rounded),
                        ),
                        const GameResults(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.exit_to_app_rounded),
                            label: const Text('Finish'),
                          ),
                        ),
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
