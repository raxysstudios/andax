import 'package:andax/editor/story_node_picker.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

class StoryNodesEditor extends StatefulWidget {
  const StoryNodesEditor({Key? key}) : super(key: key);

  @override
  State<StoryNodesEditor> createState() => _StoryNodesEditorState();
}

class _StoryNodesEditorState extends State<StoryNodesEditor>
    with SingleTickerProviderStateMixin {
  Node? node;

  late final _tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = editor.story.nodes.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Narrative'),
            Tab(
              text: 'Node ' + (node == null ? '' : '#${nodes.indexOf(node!)}'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StoryNodePicker(
            (node) => setState(() {
              this.node = node;
              _tabController.animateTo(1);
            }),
          ),
          if (node == null)
            const Text('Select node in the list')
          else
            ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: DropdownButton<Actor>(
                    icon: const SizedBox(),
                    underline: const SizedBox(),
                    value: editor.story.actors[node!.actorId],
                    onChanged: (actor) => editor.update(() {
                      node!.actorId = actor?.id;
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
                ),
                ListTile(
                  leading: const Icon(Icons.notes_rounded),
                  title: TextFormField(
                    maxLines: null,
                    initialValue: MessageTranslation.get(
                      editor.translation,
                      node!.id,
                    )?.text,
                    onChanged: (s) => editor.update(() {
                      MessageTranslation.get(
                        editor.translation,
                        node!.id,
                      )?.text = s;
                    }),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => editor.update(() {
                    editor.story.nodes.remove(node!.id);
                    editor.translation.assets.remove(node!.id);
                    node!.transitions?.forEach(
                      (t) => editor.translation.assets.remove(t.id),
                    );
                  }),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete node'),
                ),
                if (node!.transitions?.isNotEmpty ?? false)
                  for (final transition in node!.transitions!)
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => showStoryNodePickerSheet(context).then(
                              (node) => editor.update(() {
                                transition.targetNodeId = node?.id ?? '';
                              }),
                            ),
                            leading: const Icon(Icons.place_rounded),
                            title: Text(
                              MessageTranslation.getText(
                                  editor.translation, transition.id),
                            ),
                            trailing: IconButton(
                              onPressed: () => editor.update(
                                () => node!.transitions?.remove(transition),
                              ),
                              icon: const Icon(Icons.remove_rounded),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.short_text_rounded),
                            title: TextFormField(
                              maxLines: null,
                              initialValue: MessageTranslation.get(
                                editor.translation,
                                transition.id,
                              )?.text,
                              onChanged: (s) => editor.update(() {
                                MessageTranslation.get(
                                  editor.translation,
                                  transition.id,
                                )?.text = s;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                Center(
                  child: IconButton(
                    onPressed: () => editor.update(() {
                      final id = editor.uuid.v4();
                      node!.transitions ??= [];
                      node!.transitions!.add(
                        Transition(id, targetNodeId: node!.id),
                      );
                      editor.translation[id] = MessageTranslation(
                        metaData: editor.meta,
                      );
                    }),
                    tooltip: 'Add transition',
                    icon: const Icon(Icons.add_location_outlined),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
