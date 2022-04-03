import 'dart:async';

import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/node.dart';
import '../widgets/node_tile.dart';
import 'story.dart';

class NarrativeEditorScreen extends StatefulWidget {
  const NarrativeEditorScreen(
    this.onSelect, {
    this.selectedId,
    this.scroll,
    this.allowInteractive = false,
    Key? key,
  }) : super(key: key);

  final FutureOr<void> Function(Node, bool isNew) onSelect;
  final String? selectedId;
  final ScrollController? scroll;
  final bool allowInteractive;

  @override
  _NarrativeEditorScreenState createState() => _NarrativeEditorScreenState();
}

class _NarrativeEditorScreenState extends State<NarrativeEditorScreen> {
  final choices = <String, String>{};
  late var interactive = widget.allowInteractive;

  List<Node> computeThread(Story story) {
    final thread = <Node>{};
    var node = story.startNodeId == null
        ? story.nodes.values.first
        : story.nodes[story.startNodeId];

    while (node != null) {
      thread.add(node);

      final transitions = node.transitions;
      if (transitions.isEmpty) break;

      final choice = choices[node.id];
      final transition = choice == null
          ? transitions.first
          : transitions.firstWhere(
              (t) => t.id == choice,
              orElse: () => transitions.first,
            );
      node = story.nodes[transition.targetNodeId];

      if (thread.contains(node)) break;
    }
    return thread.toList();
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = editor.story.nodes.isEmpty
        ? <Node>[]
        : interactive
            ? computeThread(editor.story)
            : editor.story.nodes.values.toList();

    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Story narrative'),
        actions: [
          if (widget.allowInteractive)
            IconButton(
              onPressed: () => setState(() {
                interactive = !interactive;
              }),
              tooltip: 'Toggle view',
              icon: Icon(
                interactive
                    ? Icons.view_list_rounded
                    : Icons.account_tree_rounded,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await widget.onSelect(
            await editNode(context),
            true,
          );
          setState(() {});
        },
        icon: const Icon(Icons.add_circle_rounded),
        label: const Text('Add node'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 76),
        controller: widget.scroll,
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          final transitions = node.transitions;
          final choice = choices[node.id] ??
              (transitions.isEmpty ? null : transitions.first.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NodeTile(
                node,
                onTap: () async {
                  await widget.onSelect(node, false);
                  setState(() {});
                },
                selected: widget.selectedId == node.id,
              ),
              if (interactive && transitions.length > 1)
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    children: [
                      for (var i = 0; i < node.transitions.length; i++)
                        Builder(
                          builder: (context) {
                            final t = node.transitions[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: InputChip(
                                onPressed: () => setState(() {
                                  choices[node.id] = t.id;
                                }),
                                selected: choice == t.id,
                                label: Text(editor.tr[t.id] ?? '[tr-${i + 1}]'),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
