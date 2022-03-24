import 'package:andax/models/cell_check.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/screens/node.dart';
import 'package:andax/modules/editor/screens/story.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Node> editNode(
  BuildContext context, [
  Node? node,
]) async {
  final editor = context.read<StoryEditorState>();
  if (node == null) {
    final id = editor.uuid.v4();
    node = Node(id);
    editor.story.nodes[id] = node;
    editor.translation[id] = MessageTranslation(id);
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

void deleteNode(
  BuildContext context,
  Node node, [
  VoidCallback? onDone,
]) async {
  if (await showDangerDialog(context, 'Delete node?')) {
    final editor = context.read<StoryEditorState>();
    editor.story.nodes.remove(node.id);
    editor.translation.assets.remove(node.id);
    for (var t in node.transitions) {
      editor.translation.assets.remove(t.id);
    }
    onDone?.call();
  }
}

void migrateNodeTransitions(BuildContext context, Node node) {
  final editor = context.read<StoryEditorState>();
  for (var i = 0; i < node.transitions.length; i++) {
    final t = node.transitions[i];
    if (node.input == NodeInputType.select) {
      editor.translation[t.id] = MessageTranslation(
        t.id,
        text: 'Transition ${i + 1}',
      );
    } else {
      editor.translation.assets.remove(t.id);
    }
    if (node.input != NodeInputType.none) {
      t.condition.cellId = 'node';
      t.condition.operator = CheckOperator.equal;
      t.condition.value = i.toString();
    }
  }
}
