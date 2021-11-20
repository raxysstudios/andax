import 'package:flutter/material.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({Key? key}) : super(key: key);

  @override
  _StoryEditorScreenState createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final pageController = PageController();
  var page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Editor'),
      ),
      body: PageView.builder(
        controller: pageController,
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
                        color: page == i
                            ? Theme.of(context).toggleableActiveColor
                            : null,
                      ),
                      onPressed: () => setState(
                        () {
                          page = i;
                          pageController.animateToPage(
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
    );
  }
}
