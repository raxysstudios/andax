import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/utils.dart';
import 'package:andax/widgets/loading_builder.dart';
import 'package:andax/widgets/story_card.dart';
import 'package:andax/widgets/story_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/story.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _StoriesCategory {
  _StoriesCategory(
    this.icon,
    this.title,
    this.index, {
    this.itemCount = 10,
    this.isList = false,
  });

  final IconData icon;
  final String title;
  final String index;
  final int itemCount;
  final bool isList;
}

class _HomeScreenState extends State<HomeScreen> {
  var query = '';
  var isSearching = false;

  Future<List<StoryInfo>> getStories(int page, StoryInfo? last) async {
    return await algolia.instance
        .index('stories')
        .query('')
        .setPage(page)
        // .filters('language:${settings.targetLanguage}')
        .getObjects()
        .then(
          (s) => s.hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList(),
        );
  }

  // IconButton(
  //   onPressed: () async {
  //     await Navigator.push<void>(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const ProfileScreen(),
  //       ),
  //     );
  //     setState(() {});
  //   },
  //   icon: const Icon(Icons.person_rounded),
  // ),

  final categories = <_StoriesCategory>[
    _StoriesCategory(
      Icons.whatshot_rounded,
      'trending now',
      'stories_trending',
    ),
    _StoriesCategory(
      Icons.thumb_up_rounded,
      'most popular',
      'stories',
    ),
    _StoriesCategory(
      Icons.fiber_new_rounded,
      'recently updated',
      'stories_updated',
      itemCount: 30,
      isList: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
      ),
      floatingActionButton: FirebaseAuth.instance.currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoryEditorScreen(),
                ),
              ),
              child: const Icon(Icons.edit_rounded),
            ),
      // body: PagingList<StoryInfo>(
      //   onRequest: getStories,
      //   builder: (context, info, index) {
      //     return StoryTile(
      //       info,
      //       onTap: () => Navigator.push<void>(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => StoryScreen(info),
      //         ),
      //       ),
      //     );
      //   },
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var category in categories) ...[
              ListTile(
                leading: Icon(category.icon),
                horizontalTitleGap: 0,
                title: Text(
                  capitalize(category.title),
                  style: Theme.of(context).textTheme.headline6,
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {},
              ),
              LoadingBuilder(
                future: algolia.instance
                    .index(category.index)
                    .query('')
                    .setHitsPerPage(category.itemCount)
                    .getObjects()
                    .then(
                      (r) => r.hits
                          .map((h) => StoryInfo.fromAlgoliaHit(h))
                          .toList(),
                    ),
                builder: (context, stories) {
                  final s = stories as List<StoryInfo>;
                  if (category.isList) {
                    return Column(
                      children: [
                        for (final story in s)
                          StoryTile(
                            story,
                            onTap: () {},
                          ),
                      ],
                    );
                  }
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemExtent: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: s.length,
                      itemBuilder: (context, index) {
                        final story = s[index];
                        return StoryCard(
                          story,
                          onTap: () {},
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
