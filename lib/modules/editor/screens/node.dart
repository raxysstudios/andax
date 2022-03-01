import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/screens/actors.dart';
import 'package:andax/modules/editor/screens/narrative.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../widgets/actor_editor_dialog.dart';
import '../widgets/actor_tile.dart';
import 'story.dart';

Future<Node> openNodeEditor(
  BuildContext context, [
  Node? node,
]) async {
  final editor = context.read<StoryEditorState>();
  if (node == null) {
    final id = editor.uuid.v4();
    node = Node(id);
    editor.story.nodes[id] = node;
    editor.translation[id] = MessageTranslation(id: id);
  }
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Provider.value(
          value: editor,
          child: NodeEditorScreen(node!),
        );
      },
    ),
  );
  return node;
}

class NodeEditorScreen extends StatefulWidget {
  const NodeEditorScreen(
    this.node, {
    Key? key,
  }) : super(key: key);

  final Node node;

  @override
  State<NodeEditorScreen> createState() => _NodeEditorScreenState();
}

class _NodeEditorScreenState extends State<NodeEditorScreen> {
  Node get node => widget.node;
  List<Transition> get transitions => node.transitions ?? [];

  @override
  void initState() {
    super.initState();
    if (node.actorId == null &&
        MessageTranslation.getText(
          context.read<StoryEditorState>().translation,
          node.id,
          '',
        ).isEmpty) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) => selectActor(),
      );
    }
  }

  void selectTransitionNode(Transition transition) {
    final editor = context.read<StoryEditorState>();
    showScrollableModalSheet<Node>(
      context: context,
      builder: (context, scroll) {
        return Provider.value(
          value: editor,
          child: Builder(
            builder: (context) {
              return NarrativeEditorScreen(
                (n, _) {
                  Navigator.pop(context);
                  setState(() {
                    transition.targetNodeId = n.id;
                  });
                },
                scroll: scroll,
                selectedId: transition.targetNodeId,
              );
            },
          ),
        );
      },
    );
  }

  void selectActor() {
    final editor = context.read<StoryEditorState>();
    showScrollableModalSheet<Actor>(
      context: context,
      builder: (context, scroll) {
        return Provider.value(
          value: editor,
          child: Builder(
            builder: (context) {
              return ActorsEditorScreen(
                (actor, isNew) {
                  Navigator.pop(context);
                  setState(() {
                    node.actorId = actor?.id;
                  });
                },
                scroll: scroll,
                allowNone: true,
                selectedId: node.actorId,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    final editor = context.watch<StoryEditorState>();
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
                editor.story.nodes.remove(node.id);
                editor.translation.assets.remove(node.id);
                node.transitions?.forEach(
                  (t) => editor.translation.assets.remove(t.id),
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
          final id = editor.uuid.v4();
          node.transitions ??= [];
          final transition = Transition(id, targetNodeId: node.id);
          node.transitions!.add(transition);
          editor.translation[id] = MessageTranslation(id: id);
          selectTransitionNode(transition);
        }),
        icon: const Icon(Icons.add_location_rounded),
        label: const Text('Add transition'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          Builder(
            builder: (context) {
              final actor = editor.story.actors[node.actorId];
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
                )?.text = s;
              },
            ),
          ),
          SwitchListTile(
            value: editor.story.startNodeId == node.id,
            onChanged: (v) => setState(() {
              editor.story.startNodeId = v ? node.id : null;
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
                      editor.translation,
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
                  title: TextFormField(
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Transition text',
                      prefixIcon: Icon(Icons.short_text_rounded),
                    ),
                    initialValue: MessageTranslation.getText(
                      editor.translation,
                      transition.id,
                      '',
                    ),
                    onChanged: (s) {
                      MessageTranslation.get(
                        editor.translation,
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