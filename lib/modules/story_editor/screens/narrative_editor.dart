import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/node_editor.dart';
import 'package:flutter/material.dart';

import '../widgets/narrative_list_view.dart';

class StoryNarrativeEditorScreen extends StatefulWidget {
  const StoryNarrativeEditorScreen(
    this.editor, {
    Key? key,
  }) : super(key: key);

  final StoryEditorState editor;

  @override
  _StoryNarrativeEditorScreenState createState() =>
      _StoryNarrativeEditorScreenState();
}

class _StoryNarrativeEditorScreenState
    extends State<StoryNarrativeEditorScreen> {
  var interactive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Narrative'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              interactive = !interactive;
            }),
            tooltip: 'Toggle view',
            icon: Icon(interactive
                ? Icons.view_list_rounded
                : Icons.account_tree_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = widget.editor.uuid.v4();
          final node = Node(id);
          widget.editor.story.nodes[id] = node;
          widget.editor.translation[id] = MessageTranslation(id: id);
          await openNode(context, widget.editor, node);
          setState(() {});
        },
        tooltip: 'Add node',
        child: const Icon(Icons.add_box_rounded),
      ),
      body: NarrativeListView(
        widget.editor,
        onSelected: (n) => openNode(context, widget.editor, n),
        interactive: interactive,
        padding: const EdgeInsets.only(bottom: 76),
      ),
    );
  }
}
