import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/info_editor.dart';
import 'package:andax/shared/widgets/maybe_pop_alert.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';

import '../widgets/narrative_list_view.dart';
import '../widgets/node_editor.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({
    this.story,
    this.translation,
    this.info,
    Key? key,
  }) : super(key: key);

  final Story? story;
  final Translation? translation;
  final StoryInfo? info;

  @override
  StoryEditorState createState() => StoryEditorState();
}

class StoryEditorState extends State<StoryEditorScreen> {
  final uuid = const Uuid();

  late StoryInfo? info = widget.info;
  late final Story story = widget.story ??
      Story(
        nodes: [],
        startNodeId: '',
        actors: [],
      );
  late final Translation translation = widget.translation ??
      Translation(
        language: '',
        assets: {
          'story': StoryTranslation(
            id: '',
            title: 'New story',
          )
        },
      );

  var interactive = false;

  void openNode(Node node) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NodeEditor(this, node);
        },
      ),
    );
    setState(() {});
  }

  void openInfo() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StoryInfoEditor(this);
        },
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (info == null) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) => openInfo(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaybePopAlert(
      child: Scaffold(
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
                  ? Icons.view_list_rounded
                  : Icons.account_tree_rounded),
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final id = uuid.v4();
            final node = Node(id);
            story.nodes[id] = node;
            translation[id] = MessageTranslation(id: id);
            openNode(node);
          },
          tooltip: 'Add node',
          child: const Icon(Icons.add_box_rounded),
        ),
        body: NarrativeListView(
          this,
          onSelected: openNode,
          interactive: interactive,
          padding: const EdgeInsets.only(bottom: 76),
        ),
      ),
    );
  }
}
