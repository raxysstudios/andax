import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/info_editor.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/maybe_pop_alert.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future upload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final sdb = FirebaseFirestore.instance.collection('stories');
    var sid = widget.info?.storyID;
    if (sid == null) {
      sid = await sdb.add(story.toJson()).then((r) => r.id);
    } else {
      await sdb.doc(widget.info?.storyID).update(story.toJson());
    }
    await sdb.doc(sid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final tdb = sdb.doc(sid).collection('translations');
    var tid = widget.info?.translationID;
    if (tid == null) {
      tid = await tdb.add(translation.toJson()).then((r) => r.id);
    } else {
      await tdb.doc(tid).update(translation.toJson());
    }
    await tdb.doc(tid).update({
      'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
      'metaData.authorId': uid,
    });

    final adb = tdb.doc(tid).collection('assets');
    await Future.wait([
      for (final entry in translation.assets.entries)
        adb.doc(entry.key).set(entry.value.toJson())
    ]);

    info ??= StoryInfo(
      storyID: sid!,
      storyAuthorID: '',
      translationID: tid!,
      translationAuthorID: '',
      title: '',
    );
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
              onPressed: () async {
                await showLoadingDialog(context, upload());
                Navigator.maybePop(context);
              },
              tooltip: 'Upload story',
              icon: Icon(
                Icons.cloud_upload_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: openInfo,
              tooltip: 'Edit story info',
              icon: const Icon(Icons.info_rounded),
            ),
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
