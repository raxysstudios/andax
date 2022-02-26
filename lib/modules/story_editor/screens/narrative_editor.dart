import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/node_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/node_tile.dart';

class StoryNarrativeEditorScreen extends StatefulWidget {
  const StoryNarrativeEditorScreen({Key? key}) : super(key: key);

  @override
  _StoryNarrativeEditorScreenState createState() =>
      _StoryNarrativeEditorScreenState();
}

class _StoryNarrativeEditorScreenState
    extends State<StoryNarrativeEditorScreen> {
  final choices = <String, String>{};
  var interactive = false;

  List<Node> computeThread(Story story) {
    final thread = <Node>{};
    var node = story.startNodeId == null
        ? story.nodes.values.first
        : story.nodes[story.startNodeId];

    while (node != null) {
      thread.add(node);

      final transitions = node.transitions ?? [];
      if (transitions.isEmpty) break;

      final choice = choices[node.id];
      final transition = choice == null
          ? transitions.first
          : transitions.firstWhere((t) => t.id == choice);
      node = story.nodes[transition.targetNodeId];

      if (thread.contains(node)) break;
    }
    return thread.toList();
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = interactive
        ? computeThread(editor.story)
        : editor.story.nodes.values.toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Story narrative'),
        actions: [
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
          final node = createNode(editor);
          await openNode(context, node);
          setState(() {});
        },
        icon: const Icon(Icons.add_circle_rounded),
        label: const Text('Add node'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 76),
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          final transitions = node.transitions ?? [];
          final choice = choices[node.id] ??
              (transitions.isEmpty ? null : transitions.first.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NodeTile(
                node,
                onTap: () async {
                  await openNode(context, node);
                  setState(() {});
                },
              ),
              if (interactive && transitions.length > 1)
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    children: [
                      for (final transition in transitions)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InputChip(
                            onPressed: () => setState(() {
                              choices[node.id] = transition.id;
                            }),
                            selected: choice == transition.id,
                            label: Text(
                              MessageTranslation.getText(
                                editor.translation,
                                transition.id,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
