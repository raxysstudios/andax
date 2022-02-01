import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/screens/profile_screen.dart';
import 'package:andax/screens/search_screen.dart';
import 'package:andax/screens/story_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/utils.dart';
import 'package:andax/widgets/loading_builder.dart';
import 'package:andax/widgets/paging_list.dart';
import 'package:andax/widgets/raxys_logo.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:andax/widgets/scrollable_modal_sheet.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  Future<List<StoryInfo>> getStories(
    String index, {
    int? page,
    int? hitsPerPage,
  }) async {
    var query = algolia.instance.index(index).query('');
    if (page != null) query = query.setPage(page);
    if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);
    final hits = await query.getObjects().then((s) => s.hits);
    return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
  }

  Widget categoryCards(IconData icon, String title, String index) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          horizontalTitleGap: 0,
          title: Text(
            capitalize(title),
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => categorySheet(title, index),
        ),
        LoadingBuilder<List<StoryInfo>>(
          future: getStories(index, hitsPerPage: 10),
          builder: (context, stories) {
            return SizedBox(
              height: 128,
              child: ListView.builder(
                itemExtent: 200,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story,
                    onTap: () => openStory(story),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> categorySheet(String title, String index) async {
    await showScrollableModalSheet<void>(
      context: context,
      builder: (context, scroll) {
        return Scaffold(
          appBar: AppBar(
            leading: const RoundedBackButton(),
            title: Text(capitalize(title)),
            actions: [
              IconButton(
                onPressed: openSearch,
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search stories',
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: PagingList<StoryInfo>(
            onRequest: (p, l) => getStories(index, page: p),
            maxPages: 5,
            scroll: scroll,
            builder: (context, info, index) {
              return StoryTile(
                info,
                onTap: () => openStory(info),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> openSearch() {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  Future<void> openStory(StoryInfo info) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: const RaxysLogo(
          opacity: .1,
          scale: 3,
        ),
        title: const Text(
          'Ændax',
          style: TextStyle(fontSize: 28),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.person_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FirebaseAuth.instance.currentUser == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoryEditorScreen(),
                ),
              ),
              icon: const Icon(Icons.add_circle_rounded),
              label: const Text('Create'),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 76),
        child: Column(
          children: [
            categoryCards(
              Icons.whatshot_rounded,
              'trending now',
              'stories_trending',
            ),
            categoryCards(
              Icons.thumb_up_rounded,
              'most popular',
              'stories',
            ),
            ListTile(
              leading: const Icon(Icons.explore_rounded),
              horizontalTitleGap: 0,
              title: Text(
                capitalize('explore new'),
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: const Icon(Icons.search_rounded),
              onTap: openSearch,
            ),
            LoadingBuilder<List<StoryInfo>>(
              future: algolia
                  .index('stories_explore')
                  .query('')
                  .setHitsPerPage(0)
                  .getObjects()
                  .then((r) {
                return getStories(
                  'stories_explore',
                  page: r.nbHits ~/ 30,
                  hitsPerPage: 30,
                );
              }),
              builder: (context, stories) {
                return Column(
                  children: [
                    for (var story in stories)
                      StoryTile(
                        story,
                        onTap: () => openStory(story),
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
