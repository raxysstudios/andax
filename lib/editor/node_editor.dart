import 'package:andax/editor/narrative_sliver.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'actor_picker.dart';
import 'story_editor_screen.dart';

class NodeEditor extends StatefulWidget {
  const NodeEditor(
    this.node, {
    Key? key,
  }) : super(key: key);

  final Node node;

  @override
  State<NodeEditor> createState() => _NodeEditorState();
}

class _NodeEditorState extends State<NodeEditor> {
  Node get node => widget.node;

  List<Transition>? get transitions => node.transitions;

  @override
  Widget build(BuildContext context) {
    final editor = context.read<StoryEditorState>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          final id = editor.uuid.v4();
          node.transitions ??= [];
          node.transitions!.add(
            Transition(id, targetNodeId: node.id),
          );
          editor.translation[id] = MessageTranslation(
            metaData: editor.meta,
          );
        }),
        child: const Icon(Icons.add_location_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: const RoundedBackButton(),
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
            forceElevated: true,
            floating: true,
            snap: true,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Builder(
                builder: (context) {
                  final actor = editor.story.actors[node.actorId];
                  return ListTile(
                    onTap: () => showActorPickerSheet(
                      context,
                      node.actorId,
                    ).then(
                      (actor) => setState(() {
                        node.actorId = actor?.id;
                      }),
                    ),
                    leading: Icon(actor == null
                        ? Icons.person_rounded
                        : actor.type == ActorType.npc
                            ? Icons.smart_toy_rounded
                            : Icons.face_rounded),
                    title: Text(
                      ActorTranslation.getName(
                        editor.translation,
                        node.actorId ?? '',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notes_rounded),
                title: TextFormField(
                  maxLines: null,
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
              if (transitions?.isNotEmpty ?? false) ...[
                const Divider(),
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
              ]
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final transition = transitions?[index];
                if (transition == null) return const SizedBox();
                return Column(
                  children: [
                    ListTile(
                      onTap: () => showStoryNodePickerSheet(
                        context,
                        transition.targetNodeId,
                      ).then(
                        (node) {
                          if (node != null) {
                            setState(() {
                              transition.targetNodeId = node.id;
                            });
                          }
                        },
                      ),
                      leading: const Icon(Icons.place_rounded),
                      title: Text(
                        MessageTranslation.getText(
                          editor.translation,
                          transition.targetNodeId,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => setState(
                          () => transitions?.remove(transition),
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
                          editor.translation,
                          transition.id,
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
                );
              },
              childCount: transitions?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
