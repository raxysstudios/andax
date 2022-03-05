import 'package:andax/models/node.dart';
import 'package:andax/modules/story_editor/screens/node_editor.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/node_tile.dart';
import 'package:andax/shared/widgets/modal_picker.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Node?> showNodePickerSheet(
  BuildContext context, [
  String? selectedId,
]) {
  final editor = context.read<StoryEditorState>();
  return showModalPicker(
    context,
    (context, scroll) {
      final nodes = editor.story.nodes.values.toList();
      return Provider.value(
        value: editor,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                leading: const RoundedBackButton(),
                title: const Text('Pick node'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final node = createNode(editor);
                  await openNode(context, node);
                  Navigator.pop<Node>(context, node);
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
                      Navigator.pop<Node>(context, node);
                    },
                    selected: selectedId == node.id,
                  );
                },
              ),
            );
          },
        ),
      );
    },
  );
}
