import 'package:andax/models/cell_write.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/modules/editor/utils/node.dart';
import 'package:andax/modules/editor/utils/pickers.dart';
import 'package:andax/modules/editor/widgets/image_data_editor.dart';
import 'package:andax/modules/editor/widgets/transition_editor.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/options_button.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../widgets/actor_editor.dart';
import '../widgets/actor_tile.dart';
import '../widgets/cell_write_editor.dart';
import 'story.dart';

class NodeEditorScreen extends StatefulWidget {
  const NodeEditorScreen(
    this.node, {
    Key? key,
  }) : super(key: key);

  final Node node;

  @override
  State<NodeEditorScreen> createState() => _NodeEditorScreenState();
}

class _NodeEditorScreenState extends State<NodeEditorScreen>
    with SingleTickerProviderStateMixin {
  late final tabs = TabController(vsync: this, length: 3);

  Node get node => widget.node;
  List<Transition> get transitions => node.transitions;

  @override
  void initState() {
    super.initState();
    if (node.actorId == null && node.transitions.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => pickActor(context, node).then(
          (r) => setState(() => node.actorId = r?.id),
        ),
      );
    }
  }

  Widget buildContentsTab(StoryEditorState editor) {
    return ListView(
      children: [
        Builder(
          builder: (context) {
            final actor = editor.story.actors[node.actorId];
            return ActorTile(
              actor,
              onTap: () => pickActor(context, node).then(
                (r) => setState(() => node.actorId = r?.id),
              ),
              onLongPress: actor == null
                  ? null
                  : () => showActorEditor(context, actor)
                      .then((r) => setState(() {})),
              allowNarrator: true,
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.notes_rounded),
          title: TextFormField(
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Message text',
            ),
            autofocus: true,
            initialValue: editor.tr.node(node),
            onChanged: (s) => editor.tr[node.id] = s.trim(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.image_rounded),
          title: const Text('Image'),
          subtitle: Text(node.image == null ? '[NO FILE]' : node.image!.url),
          onTap: () => showImageDataEditor(context, node).then(
            (r) => setState(() {}),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.audiotrack_rounded),
          title: TextFormField(
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Audio URL'),
            initialValue: editor.tr.audio(node),
            onChanged: (s) => editor.tr[node.id + '_audio'] = s.trim(),
          ),
        ),
      ],
    );
  }

  Widget buildTransitionsTab(StoryEditorState editor) {
    final transitions = node.transitions;
    return Scaffold(
      primary: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTransitionEditor(
          context,
          node,
        ).then((r) => setState(() {})),
        icon: const Icon(Icons.control_point_rounded),
        label: const Text('Add transition'),
      ),
      body: ListView(
        children: [
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.functions_rounded),
            title: const Text('Transition control'),
            subtitle: Builder(
              builder: (context) {
                final labels = ['Random', 'User select', 'Cells'];
                return Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      InputChip(
                        onPressed: () {
                          final v = NodeInputType.values[i];
                          if (node.input != v) {
                            setState(() {
                              node.input = v;
                              migrateNodeTransitions(context, node);
                            });
                          }
                        },
                        selected: node.input == NodeInputType.values[i],
                        label: Text(labels[i].titleCase),
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          for (var i = 0; i < transitions.length; i++)
            ListTile(
              title: Text(
                editor.tr[transitions[i].targetNodeId] ?? '[❌MESSAGE]',
              ),
              subtitle: editor.tr[transitions[i].id] == null
                  ? null
                  : Text(editor.tr.transition(transitions[i])),
              onTap: () => showTransitionEditor(
                context,
                node,
                transitions[i],
              ).then((r) => setState(() {})),
              trailing: Text('#${i + 1}'),
            ),
        ],
      ),
    );
  }

  Widget buildCellsTab(StoryEditorState editor) {
    final writes = node.cellWrites;
    return Scaffold(
      primary: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCellWriteEditor(
          context,
          node,
        ).then((r) => setState(() {})),
        icon: const Icon(Icons.control_point_rounded),
        label: const Text('Add cell write'),
      ),
      body: ListView(
        children: [
          for (final write in writes)
            ListTile(
              leading: Icon(
                write.mode == CellWriteMode.overwrite
                    ? Icons.drive_file_rename_outline_rounded
                    : write.mode == CellWriteMode.add
                        ? Icons.add_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
              ),
              title: Text(write.value),
              subtitle: Text(editor.tr[write.targetCellId] ?? '[❌CELL]'),
              onTap: () => showCellWriteEditor(
                context,
                node,
                write,
              ).then((r) => setState(() {})),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    final editor = context.watch<StoryEditorState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(icon: Icons.done_all_rounded),
        title: const Text('Messages editor'),
        actions: [
          OptionsButton(
            [
              OptionItem.simple(
                Icons.delete_rounded,
                'Delete message',
                () => deleteNode(
                  context,
                  node,
                  () => Navigator.pop(context),
                ),
              ),
              OptionItem.divider(),
              OptionItem(
                SwitchListTile(
                  secondary: const Icon(Icons.play_circle_rounded),
                  title: const Text('Story entry'),
                  value: editor.story.startNodeId == node.id,
                  onChanged: (r) => setState(() {
                    editor.story.startNodeId = r ? node.id : null;
                    Navigator.pop(context);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: tabs,
          labelColor: textTheme.bodyText1?.color,
          unselectedLabelColor: textTheme.caption?.color,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_rounded),
              text: 'Contents',
            ),
            Tab(
              icon: Icon(Icons.call_split_rounded),
              text: 'Transitions',
            ),
            Tab(
              icon: Icon(Icons.tune_rounded),
              text: 'Storage',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          buildContentsTab(editor),
          buildTransitionsTab(editor),
          buildCellsTab(editor),
        ],
      ),
    );
  }
}
