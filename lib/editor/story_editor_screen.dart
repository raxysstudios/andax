import 'package:andax/editor/narrative_editor.dart';
import 'package:andax/editor/story_actors_editor.dart';
import 'package:andax/editor/story_general_editor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/maybe_pop_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  final _pageController = PageController();
  var _page = 0;

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

  void update(VoidCallback action) => setState(action);

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

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Scaffold(
        body: MaybePopAlert(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, page) {
              switch (page) {
                case 0:
                  // ignore: prefer_const_constructors
                  return StoryGeneralEditor();
                case 1:
                  // ignore: prefer_const_constructors
                  return ActorsEditor();
                case 2:
                  return const NarrativeEditor();
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (i) => update(() {
            _page = i;
            _pageController.animateToPage(
              i,
              duration: kTabScrollDuration,
              curve: standardEasing,
            );
          }),
          currentIndex: _page,
          items: [
            for (final entry in {
              'General': Icons.auto_stories_rounded,
              'Actors': Icons.person_rounded,
              'Narrative': Icons.timeline_rounded,
            }.entries)
              BottomNavigationBarItem(
                icon: Icon(entry.value),
                label: entry.key,
              )
          ],
        ),
      ),
    );
  }
}
