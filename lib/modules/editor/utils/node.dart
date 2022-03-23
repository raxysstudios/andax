import 'package:andax/models/actor.dart';
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

Future<void> selectTransitionInputSource(
  BuildContext context,
  Node node,
) async {
  final editor = context.read<StoryEditorState>();
  final source = await showDialog<NodeInputType>(
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
            const Text(
              '[Warning] Changing transition type will reset current transitions!',
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                NodeInputType.random,
              ),
              child: const ListTile(
                leading: Icon(Icons.shuffle_rounded),
                title: Text('Random'),
                subtitle: Text('Picks any transition'),
              ),
            ),
            Builder(builder: (context) {
              final player =
                  editor.story.actors[node.actorId]?.type == ActorType.player;
              return SimpleDialogOption(
                onPressed: player
                    ? () => Navigator.pop(
                          context,
                          NodeInputType.select,
                        )
                    : null,
                child: ListTile(
                  leading: const Icon(Icons.touch_app_rounded),
                  title: Text(
                    'User' +
                        (node.input == NodeInputType.select
                            ? ''
                            : ' [for player-actor]'),
                  ),
                  subtitle: const Text('Selected by player on UI'),
                ),
              );
            }),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                NodeInputType.none,
              ),
              child: const ListTile(
                leading: Icon(Icons.rule_rounded),
                title: Text('Cell'),
                subtitle: Text('Based on cell values'),
              ),
            ),
          ],
        ),
      );
    },
  );
  if (source != null) {
    node.input = source;
    for (final t in node.transitions) {
      editor.translation.assets.remove(t.id);
    }
    node.transitions.clear();
  }
}
