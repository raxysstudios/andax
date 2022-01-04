import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/modal_picker.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';

import 'story_editor_screen.dart';

class NarrativeListView extends StatefulWidget {
  const NarrativeListView(
    this.editor, {
    this.onSelected,
    this.selectedId,
    this.interactive = true,
    this.padding,
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;
  final bool interactive;
  final String? selectedId;
  final ValueSetter<Node>? onSelected;
  final EdgeInsets? padding;

  @override
  State<NarrativeListView> createState() => _NarrativeListViewState();
}

class _NarrativeListViewState extends State<NarrativeListView> {
  Translation get translation => widget.editor.translation;
  Story get story => widget.editor.story;
  List<Node> get nodes => widget.editor.story.nodes.values.toList();

  final choices = <String, String>{};

  List<Node> computeThread() {
    final thread = <Node>{};
    var node = nodes.isEmpty ? null : nodes.first;
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
    final nodes = widget.interactive ? computeThread() : this.nodes;
    return ListView.builder(
      padding: widget.padding,
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
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
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
              trailing: Text(
                '#${(this.nodes.indexOf(node) + 1)}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              selected: node.id == widget.selectedId,
            ),
            if (widget.interactive && transitions.length > 1)
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
    );
  }
}

Future<Node?> showStoryNodePickerSheet(
  StoryEditorState editor,
  BuildContext context, [
  String? selectedId,
]) {
  return showModalPicker(
    context,
    (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Pick Node'),
        ),
        body: NarrativeListView(
          editor,
          onSelected: (node) => Navigator.pop(context, node),
          selectedId: selectedId,
          interactive: false,
        ),
      );
    },
  );
}
