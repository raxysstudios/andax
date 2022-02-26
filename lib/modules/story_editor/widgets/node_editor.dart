import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/widgets/actor_editor_dialog.dart';
import 'package:andax/modules/story_editor/widgets/actor_tile.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../screens/story_editor.dart';
import 'actor_picker_sheet.dart';
import 'node_picker_sheet.dart';

Future<void> openNode(
  BuildContext context,
  StoryEditorState editor,
  Node node,
) async {
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return NodeEditor(editor, node);
      },
    ),
  );
}

Node createNode(StoryEditorState editor) {
  final id = editor.uuid.v4();
  final node = Node(id);
  editor.story.nodes[id] = node;
  editor.translation[id] = MessageTranslation(id: id);
  return node;
}

class NodeEditor extends StatefulWidget {
  const NodeEditor(
    this.editor,
    this.node, {
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;
  final Node node;

  @override
  State<NodeEditor> createState() => _NodeEditorState();
}

class _NodeEditorState extends State<NodeEditor> {
  Translation get translation => widget.editor.translation;
  Node get node => widget.node;

  List<Transition> get transitions => node.transitions ?? [];

  @override
  void initState() {
    super.initState();
    if (node.actorId == null &&
        MessageTranslation.getText(translation, node.id, '').isEmpty) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) => selectActor(),
      );
    }
  }

  void selectTransitionNode(Transition transition) {
    showNodePickerSheet(
      context,
      widget.editor,
      (n) => setState(() {
        transition.targetNodeId = n.id;
      }),
      transition.targetNodeId,
    );
  }

  void selectActor() {
    showActorPickerSheet(
      context,
      (a) => setState(() {
        node.actorId = a?.id;
      }),
      node.actorId,
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(icon: Icons.done_all_rounded),
        title: const Text('Node'),
        actions: [
          IconButton(
            onPressed: () async {
              final delete = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete node?'),
                    actions: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Delete'),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Keep'),
                      ),
                    ],
                  );
                },
              );
              if (delete ?? false) {
                widget.editor.story.nodes.remove(node.id);
                translation.assets.remove(node.id);
                node.transitions?.forEach(
                  (t) => translation.assets.remove(t.id),
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Delete node',
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() {
          final id = widget.editor.uuid.v4();
          node.transitions ??= [];
          final transition = Transition(id, targetNodeId: node.id);
          node.transitions!.add(transition);
          translation[id] = MessageTranslation(id: id);
          selectTransitionNode(transition);
        }),
        icon: const Icon(Icons.add_location_rounded),
        label: const Text('Add transition'),
      ),
      body: ListView(
        children: [
          Builder(
            builder: (context) {
              final actor = widget.editor.story.actors[node.actorId];
              return ActorTile(
                actor,
                onTap: selectActor,
                onLongPress: actor == null
                    ? null
                    : () => showActorEditorDialog(
                          context,
                          (r) => setState(() {}),
                          actor,
                        ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notes_rounded),
            title: TextFormField(
              maxLines: null,
              initialValue: MessageTranslation.get(
                translation,
                node.id,
              )?.text,
              onChanged: (s) {
                MessageTranslation.get(
                  translation,
                  node.id,
                )?.text = s;
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            value: widget.editor.story.startNodeId == node.id,
            onChanged: (v) => setState(() {
              widget.editor.story.startNodeId = node.id;
            }),
            secondary: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.login_rounded),
            ),
            title: const Text('Story entry'),
            subtitle: const Text('Players start from this node'),
          ),
          if (transitions.isNotEmpty) ...[
            SwitchListTile(
              value: node.autoTransition,
              onChanged: (v) => setState(() {
                node.autoTransition = v;
              }),
              secondary: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.skip_next_rounded),
              ),
              title: const Text('Auto transition'),
              subtitle: const Text('Chooses randomly'),
            ),
            const Divider(),
          ],
          for (final transition in transitions)
            Column(
              children: [
                ListTile(
                  onTap: () => selectTransitionNode(transition),
                  leading: const Icon(Icons.place_rounded),
                  title: Text(
                    MessageTranslation.getText(
                      translation,
                      transition.targetNodeId,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => setState(
                      () => transitions.remove(transition),
                    ),
                    icon: const Icon(Icons.delete_rounded),
                    tooltip: 'Delete transition',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.short_text_rounded),
                  title: TextFormField(
                    maxLines: null,
                    initialValue: MessageTranslation.getText(
                      translation,
                      transition.id,
                    ),
                    onChanged: (s) {
                      MessageTranslation.get(
                        translation,
                        transition.id,
                      )?.text = s;
                    },
                  ),
                ),
                const Divider(),
              ],
            )
        ],
      ),
    );
  }
}
