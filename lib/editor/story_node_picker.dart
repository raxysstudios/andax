import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

class StoryNodePicker extends StatelessWidget {
  const StoryNodePicker(
    this.onSelected, {
    Key? key,
  }) : super(key: key);

  final ValueSetter<Node> onSelected;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    final nodes = editor.story.nodes.values.toList();
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return ListTile(
          onTap: () => onSelected(node),
          title: Text(
            MessageTranslation.getText(
              editor.translation,
              node.id,
            ),
          ),
        );
      },
    );
  }
}

Future<Node?> showStoryNodePickerSheet(BuildContext context) {
  return showModalBottomSheet<Node>(
    context: context,
    builder: (context) {
      return Container(
        height: 300,
        color: Colors.amber,
        child: StoryNodePicker(
          (node) => Navigator.pop(context, node),
        ),
      );
    },
  );
}
