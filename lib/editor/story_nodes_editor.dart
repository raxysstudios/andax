import 'package:andax/editor/story_node_selector.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

class StoryNodesEditor extends StatelessWidget {
  const StoryNodesEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = editor.story.nodes.values.toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: const RoundedBackButton(),
          title: Text('Nodes: ${nodes.length}'),
          forceElevated: true,
          floating: true,
          snap: true,
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final node = nodes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: const RoundedRectangleBorder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: DropdownButton<Actor>(
                        icon: const SizedBox(),
                        underline: const SizedBox(),
                        value: editor.story.actors[node.actorId],
                        onChanged: (actor) => editor.update(() {
                          node.actorId = actor?.id;
                        }),
                        items: [
                          const DropdownMenuItem<Actor>(
                            child: Text("None"),
                          ),
                          for (final actor in editor.story.actors.values)
                            DropdownMenuItem(
                              value: actor,
                              child: Text(
                                ActorTranslation.get(
                                      editor.translation,
                                      actor.id,
                                    )?.name ??
                                    '',
                              ),
                            )
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => editor.update(() {
                          editor.story.nodes.remove(node.id);
                          editor.translation.assets.remove(node.id);
                          node.transitions?.forEach(
                            (t) => editor.translation.assets.remove(t.id),
                          );
                        }),
                        icon: const Icon(Icons.delete_rounded),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notes_rounded),
                      title: TextFormField(
                        maxLines: null,
                        initialValue: MessageTranslation.get(
                          editor.translation,
                          node.id,
                        )?.text,
                        onChanged: (s) => editor.update(() {
                          MessageTranslation.get(
                            editor.translation,
                            node.id,
                          )?.text = s;
                        }),
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      value: node.autoTransition,
                      title: const Text('Auto transition'),
                      onChanged: (v) => editor.update(() {
                        node.autoTransition = v;
                      }),
                    ),
                    if (node.transitions != null)
                      for (final transition in node.transitions!)
                        ListTile(
                          title: StoryNodeSelector(
                            editor.story.nodes[transition.targetNodeId],
                            (node) => editor.update(() {
                              transition.targetNodeId = node?.id ?? '';
                            }),
                            allowNone: false,
                          ),
                          trailing: IconButton(
                            onPressed: () => editor.update(
                              () => node.transitions?.remove(transition),
                            ),
                            icon: const Icon(Icons.remove_rounded),
                          ),
                        ),
                    OutlinedButton.icon(
                      onPressed: () => editor.update(() {
                        final id = editor.uuid.v4();
                        node.transitions ??= [];
                        node.transitions!.add(
                          Transition(id, targetNodeId: node.id),
                        );
                        editor.translation[id] = MessageTranslation(
                          metaData: editor.meta,
                        );
                      }),
                      icon: const Icon(Icons.alt_route_rounded),
                      label: const Text('Add Transition'),
                    ),
                  ],
                ),
              );
            },
            childCount: nodes.length,
          ),
        ),
      ],
    );
  }
}
