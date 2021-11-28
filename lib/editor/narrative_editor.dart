import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'narrative_list_view.dart';
import 'node_editor.dart';
import 'story_editor_screen.dart';

class NarrativeEditor extends StatefulWidget {
  const NarrativeEditor({Key? key}) : super(key: key);

  @override
  NarrativeEditorState createState() => NarrativeEditorState();
}

class NarrativeEditorState extends State<NarrativeEditor> {
  var interactive = false;

  void openNode(StoryEditorState editor, Node node) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Provider.value(
            value: editor,
            child: NodeEditor(node),
          );
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Narrative'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              interactive = !interactive;
            }),
            tooltip: 'Toggle view',
            icon: Icon(interactive
                ? Icons.account_tree_rounded
                : Icons.view_list_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final id = editor.uuid.v4();
          final node = Node(id);
          editor.story.nodes[id] = node;
          editor.translation[id] = MessageTranslation(metaData: editor.meta);
          openNode(editor, node);
        },
        tooltip: 'Add node',
        child: const Icon(Icons.add_box_rounded),
      ),
      body: NarrativeListView(
        editor,
        onSelected: (node) => openNode(editor, node),
        interactive: interactive,
        padding: const EdgeInsets.only(bottom: 76),
      ),
    );
  }
}
