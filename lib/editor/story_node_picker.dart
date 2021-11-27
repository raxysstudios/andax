import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/modal_picker.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

// TODO fix state updating.
// TODO unify with picker.

class NarrativeEditorSliver extends StatefulWidget {
  const NarrativeEditorSliver(
    this.editor, {
    this.onSelected,
    this.selectedId,
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;
  final String? selectedId;
  final ValueSetter<Node>? onSelected;

  @override
  State<NarrativeEditorSliver> createState() => _NarrativeEditorSliverState();
}

class _NarrativeEditorSliverState extends State<NarrativeEditorSliver> {
  Translation get translation => widget.editor.translation;
  Story get story => widget.editor.story;

  var choices = <String, String>{};

  List<Node> computeThread() {
    var thread = <Node>{};
    var node = story.nodes.isEmpty ? null : story.nodes.values.first;
    while (node != null) {
      thread.add(node);

      final transitions = node.transitions ?? [];
      if (transitions.isEmpty) {
        node = null;
        continue;
      }
      final choice = choices[node.id];
      final transition = choice == null
          ? transitions.first
          : transitions.firstWhere((t) => t.id == choice);
      node = story.nodes[transition.targetNodeId];

      if (thread.contains(node)) {
        node = null;
      }
    }
    return thread.toList();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = story.nodes.values.toList();
    final thread = computeThread();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final node = thread[index];
          final actor = story.actors[node.actorId];
          final transitions = node.transitions ?? [];
          final choice = choices[node.id] ??
              (transitions.isEmpty ? null : transitions.first.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                onTap: () => widget.onSelected?.call(node),
                title: Text(
                  MessageTranslation.getText(
                    translation,
                    node.id,
                  ),
                ),
                subtitle: actor == null
                    ? null
                    : Row(
                        children: [
                          Icon(
                            actor.type == ActorType.npc
                                ? Icons.smart_toy_rounded
                                : Icons.face_rounded,
                            size: 16,
                            color: Theme.of(context).textTheme.caption?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ActorTranslation.getName(
                              translation,
                              actor.id,
                            ),
                          )
                        ],
                      ),
                trailing: Text(
                  '#${(nodes.indexOf(node) + 1)}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                selected: node.id == widget.selectedId,
              ),
              if (transitions.length > 1)
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
                                translation,
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
        childCount: thread.length,
      ),
    );
  }
}

SliverList buildNodesSliverList(
  StoryEditorState editor,
  ValueSetter<Node> onSelected, [
  String? selectedId,
  List<Node>? nodes,
]) {
  nodes ??= editor.story.nodes.values.toList();
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final node = nodes![index];
        final actor = editor.story.actors[node.actorId];
        final transitions = node.transitions ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              onTap: () => onSelected(node),
              title: Text(
                MessageTranslation.getText(
                  editor.translation,
                  node.id,
                ),
              ),
              subtitle: actor == null
                  ? null
                  : Row(
                      children: [
                        Icon(
                          actor.type == ActorType.npc
                              ? Icons.smart_toy_rounded
                              : Icons.face_rounded,
                          size: 16,
                          color: Theme.of(context).textTheme.caption?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ActorTranslation.getName(
                            editor.translation,
                            actor.id,
                          ),
                        )
                      ],
                    ),
              trailing: Text(
                '#${(nodes.indexOf(node) + 1)}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              selected: node.id == selectedId,
            ),
            if (transitions.length > 1)
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
                          onPressed: () {},
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
      childCount: nodes.length,
    ),
  );
}

Future<Node?> showStoryNodePickerSheet(
  BuildContext context, [
  String? selectedId,
]) {
  final editor = context.read<StoryEditorState>();
  return showModalPicker(context, [
    const SliverAppBar(
      leading: RoundedBackButton(),
      title: Text('Pick Node'),
      forceElevated: true,
      floating: true,
      snap: true,
      pinned: true,
    ),
    buildNodesSliverList(
      editor,
      (node) => Navigator.pop(context, node),
      selectedId,
    ),
  ]);
}
