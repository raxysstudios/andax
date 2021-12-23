import 'package:andax/editor/story_info_editor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/maybe_pop_alert.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'narrative_list_view.dart';
import 'node_editor.dart';

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
  final meta = ContentMetaData(
    '',
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );

  late StoryInfo? info = widget.info;
  late final Story story = widget.story ??
      Story(
        nodes: {},
        startNodeId: '',
        actors: {},
        metaData: meta,
      );
  late final Translation translation = widget.translation ??
      Translation(
        language: '',
        metaData: meta,
        assets: {
          'story': StoryTranslation(
            title: 'New story',
            metaData: meta,
          )
        },
      );

  var interactive = false;

  void openNode(Node node) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NodeEditor(
            editor: this,
            node: node,
          );
        },
      ),
    );
    setState(() {});
  }

  Future upload() async {
    final sdb = FirebaseFirestore.instance.collection('stories');
    var sid = widget.info?.storyID;
    if (sid == null) {
      sid = await sdb.add(story.toJson()).then((r) => r.id);
    } else {
      await sdb.doc(widget.info?.storyID).set(story.toJson());
    }

    final tdb = sdb.doc(sid).collection('translations');
    var tid = widget.info?.translationID;
    if (tid == null) {
      tid = await tdb.add(translation.toJson()).then((r) => r.id);
    } else {
      await tdb.doc(tid).set(translation.toJson());
    }

    final adb = tdb.doc(tid).collection('assets');
    await Future.wait([
      for (final entry in translation.assets.entries)
        adb.doc(entry.key).set(entry.value.toJson())
    ]);
    info ??= StoryInfo(
      storyID: sid!,
      translationID: tid!,
      title: '',
    );
  }

  final scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaybePopAlert(
      child: Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Narrative'),
          actions: [
            IconButton(
              onPressed: upload,
              tooltip: 'Upload story',
              icon: Icon(
                Icons.cloud_upload_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StoryInfoEditor(
                      editor: this,
                    );
                  }),
                );
                setState(() {});
              },
              tooltip: 'Edit story info',
              icon: const Icon(Icons.info_rounded),
            ),
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
            final id = uuid.v4();
            final node = Node(id);
            story.nodes[id] = node;
            translation[id] = MessageTranslation(metaData: meta);
            openNode(node);
          },
          tooltip: 'Add node',
          child: const Icon(Icons.add_box_rounded),
        ),
        body: NarrativeListView(
          this,
          controller: scroll,
          onSelected: openNode,
          interactive: interactive,
          padding: const EdgeInsets.only(bottom: 76),
        ),
      ),
    );
  }
}
