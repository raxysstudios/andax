import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';
import 'story_node_selector.dart';

class StoryNodeEditor extends StatefulWidget {
  const StoryNodeEditor(
    this.node, {
    Key? key,
  }) : super(key: key);

  final Node node;

  @override
  _StoryNodeEditorState createState() => _StoryNodeEditorState();
}

class _StoryNodeEditorState extends State<StoryNodeEditor> {
  final _pageController = PageController();
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = editor.story.nodes.values.toList();
    final node = widget.node;
    return Column(
      children: [
        Row(
          children: [
            Text('#${nodes.indexOf(node)}'),
            ToggleButtons(
              children: const [
                Icon(Icons.chat_bubble_rounded),
                Icon(Icons.alt_route_rounded)
              ],
              isSelected: [
                _page == 0,
                _page == 1,
              ],
              onPressed: (index) => setState(
                () {
                  _page = index;
                  _pageController.animateToPage(
                    index,
                    duration: kTabScrollDuration,
                    curve: standardEasing,
                  );
                },
              ),
            ),
          ],
        ),
        PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Column(
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
                    TextButton.icon(
                      onPressed: () => editor.update(() {
                        editor.story.nodes.remove(node.id);
                        editor.translation.assets.remove(node.id);
                        node.transitions?.forEach(
                          (t) => editor.translation.assets.remove(t.id),
                        );
                      }),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete node'),
                    ),
                  ],
                );
              case 1:
                return PageView.builder(
                  itemCount: (node.transitions?.length ?? 0) + 1,
                  itemBuilder: (constext, index) {
                    if (index == (node.transitions?.length ?? 0)) {
                      return Center(
                        child: IconButton(
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
                          tooltip: 'Add transition',
                          icon: const Icon(Icons.add_location_outlined),
                        ),
                      );
                    }
                    final transition = node.transitions?[index];
                    if (transition == null) return const SizedBox();
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.place_rounded),
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
                    );
                  },
                );
              default:
                return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
