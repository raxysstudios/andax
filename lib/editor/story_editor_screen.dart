import 'package:andax/editor/story_actors_editor.dart';
import 'package:andax/editor/story_general_editor.dart';
import 'package:andax/editor/story_nodes_editor.dart';
import 'package:andax/models/actor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({Key? key}) : super(key: key);

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

  late var story = Scenario(
    nodes: {},
    startNodeId: '',
    actors: {},
    metaData: meta,
  );
  late var translation = Translation(
    language: '',
    metaData: meta,
    assets: {},
  );

  void update(VoidCallback action) => setState(action);

  Future upload() async {
    final sdb = FirebaseFirestore.instance.collection('stories');
    final sid = await sdb.add(story.toJson()).then((r) => r.id);
    final tdb = sdb.doc(sid).collection('translations');
    final tid = await tdb.add(translation.toJson()).then((r) => r.id);
    final adb = tdb.doc(tid).collection('assets');
    await Future.wait([
      for (final entry in translation.assets.entries)
        adb.doc(entry.key).set(entry.value.toJson())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Scaffold(
        body: SafeArea(
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
                  return StoryActorsEditor();
                case 2:
                  // ignore: prefer_const_constructors
                  return StoryNodesEditor();
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            switch (_page) {
              case 0:
                return FloatingActionButton(
                  onPressed: () => showLoadingDialog(context, upload()),
                  tooltip: 'Upload story',
                  child: const Icon(Icons.upload_rounded),
                );
              case 1:
                return FloatingActionButton(
                  onPressed: () => setState(
                    () {
                      final id = uuid.v4();
                      story.actors[id] = Actor(id: id);
                      translation[id] = ActorTranslation(metaData: meta);
                    },
                  ),
                  tooltip: 'Add actor',
                  child: const Icon(Icons.person_add_rounded),
                );
              case 2:
                return FloatingActionButton(
                  onPressed: () => setState(() {
                    final id = uuid.v4();
                    story.nodes[id] = Node(id);
                    translation[id] = MessageTranslation(metaData: meta);
                  }),
                  tooltip: 'Add node',
                  child: const Icon(Icons.add_box_rounded),
                );
              default:
                return const SizedBox();
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Builder(builder: (context) {
              final pages = {
                'General': Icons.auto_stories_rounded,
                'Actors': Icons.person_rounded,
                'Nodes': Icons.timeline_rounded,
              }.entries.toList();
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        tooltip: pages[i].key,
                        icon: Icon(
                          pages[i].value,
                          color: _page == i
                              ? Theme.of(context).toggleableActiveColor
                              : null,
                        ),
                        onPressed: () => setState(
                          () {
                            _page = i;
                            _pageController.animateToPage(
                              i,
                              duration: kTabScrollDuration,
                              curve: standardEasing,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
