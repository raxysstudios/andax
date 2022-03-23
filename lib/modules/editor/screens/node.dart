import 'package:andax/models/actor.dart';
import 'package:andax/models/cell_write.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/utils/node.dart';
import 'package:andax/modules/editor/utils/pickers.dart';
import 'package:andax/modules/editor/widgets/transition_editor.dart';
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
    if (node.actorId == null &&
        MessageTranslation.getText(
          context.read<StoryEditorState>().translation,
          node.id,
        ).isEmpty) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) => pickActor(context, node).then(
          (r) => setState(() {
            node.actorId = r?.id;
          }),
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
                (r) {
                  if (r?.type != ActorType.player &&
                      node.input ==
                          NodeInputType.select) {
                    node.input = NodeInputType.random;
                  }
                  node.actorId = r?.id;
                  setState(() {});
                },
              ),
              onLongPress: actor == null
                  ? null
                  : () => showActorEditor(context, actor)
                      .then((r) => setState(() {})),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: TextFormField(
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Message text',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            autofocus: true,
            initialValue: MessageTranslation.get(
              editor.translation,
              node.id,
            )?.text,
            onChanged: (s) {
              MessageTranslation.get(
                editor.translation,
                node.id,
              )?.text = s.trim();
            },
          ),
        ),
        const ListTile(
          leading: Icon(Icons.image_rounded),
          title: Text('Select image'),
          subtitle: Text('<NOT IMPLEMENTED>'),
        ),
        const ListTile(
          leading: Icon(Icons.audiotrack_rounded),
          title: Text('Select audio'),
          subtitle: Text('<NOT IMPLEMENTED>'),
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
            leading: const Icon(Icons.functions_rounded),
            title: Text('Determined by "${node.input.name}"'),
            subtitle: const Text('Transition input source'),
            onTap: () => selectTransitionInputSource(context, node).then(
              (r) => setState(() {}),
            ),
          ),
          const Divider(),
          for (var i = 0; i < transitions.length; i++)
            ListTile(
              title: Text(
                MessageTranslation.getText(
                  editor.translation,
                  transitions[i].id,
                ),
              ),
              subtitle: Text(
                MessageTranslation.getText(
                  editor.translation,
                  transitions[i].targetNodeId,
                ),
              ),
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
        onPressed: () => showCellWrite(
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
              subtitle: Text(MessageTranslation.getText(
                  editor.translation, write.targetCellId)),
              onTap: () => showCellWrite(
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
        title: const Text('Node editor'),
        actions: [
          OptionsButton(
            [
              OptionItem.simple(
                Icons.delete_rounded,
                'Delete node',
                () => deleteNode(
                  context,
                  node,
                  () => Navigator.pop(context),
                ),
              ),
              null,
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
