import 'package:andax/models/node.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/node_editor.dart';
import 'package:andax/modules/story_editor/widgets/node_tile.dart';
import 'package:andax/shared/widgets/modal_picker.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Node?> showNodePickerSheet(
  BuildContext context,
  ValueSetter<Node> onSelect, [
  String? selectedId,
]) {
  return showModalPicker(
    context,
    (context, scroll) {
      final editor = context.read<StoryEditorState>();
      final nodes = editor.story.nodes.values.toList();
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Pick node'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final node = createNode(editor);
            await openNode(context, editor, node);
            Navigator.pop(context);
            onSelect(node);
          },
          tooltip: 'Add node',
          child: const Icon(Icons.add_circle_rounded),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(bottom: 76),
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            return NodeTile(
              node,
              onTap: () {
                Navigator.pop(context);
                onSelect(node);
              },
              selected: selectedId == node.id,
            );
          },
        ),
      );
    },
  );
}
