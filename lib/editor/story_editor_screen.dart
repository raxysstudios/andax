import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/translation.dart';
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
  final _meta = ContentMetaData(
    '',
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );

  late var story = Scenario(
    nodes: {},
    startNodeId: '',
    actors: {},
    metaData: _meta,
  );
  late var translation = Translation(
    language: '',
    metaData: _meta,
    assets: {},
  );

  void update(VoidCallback action) => setState(action);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Story Editor'),
        ),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, page) {
            switch (page) {
              case 0:
                return const Text('General');
              case 1:
                return const Text('Actors');
              case 2:
                return const Text('Nodes');
              default:
                return const SizedBox();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.library_add_rounded),
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
              return Row(
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
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInSine,
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
