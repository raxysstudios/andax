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
    node.transitions?.forEach(
      (t) => editor.translation.assets.remove(t.id),
    );
    onDone?.call();
  }
}

void selectTransitionInputSource(BuildContext context, Node node) async {
  final source = await showDialog<TransitionInputSource>(
    context: context,
    builder: (BuildContext context) {
      return ListTileTheme(
        data: const ListTileThemeData(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 0,
        ),
        child: SimpleDialog(
          title: const Text('Select input source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                TransitionInputSource.random,
              ),
              child: const ListTile(
                leading: Icon(Icons.shuffle_rounded),
                title: Text('Random choice'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                TransitionInputSource.select,
              ),
              child: const ListTile(
                leading: Icon(Icons.touch_app_rounded),
                title: Text('Selected by user'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                TransitionInputSource.store,
              ),
              child: const ListTile(
                leading: Icon(Icons.rule_rounded),
                title: Text("Based on cells' values"),
              ),
            ),
          ],
        ),
      );
    },
  );
  if (source != null) node.transitionInputSource = source;
}
