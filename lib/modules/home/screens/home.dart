import 'package:andax/models/story.dart';
import 'package:andax/modules/editor/screens/story.dart';
import 'package:andax/modules/home/widgets/raxys_logo.dart';
import 'package:andax/modules/home/widgets/story_category_list.dart';
import 'package:andax/modules/home/widgets/story_tile.dart';
import 'package:andax/modules/profile/screens/auth_gate.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/loading_builder.dart';
import 'package:andax/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/searching.dart';
import '../services/sheets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {});
    });
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
        title: const Text('Ændax'),
        actions: [
          IconButton(
            onPressed: () => showSearchSheet(context),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search stories',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthGate(),
                ),
              );
              setState(() {});
            },
            icon: Icon(user == null ? Icons.login : Icons.person_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoryEditorScreen(),
                  ),
                );
                setState(() {});
              },
              icon: const Icon(Icons.create_rounded),
              label: const Text('Create'),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 76),
        child: Column(
          children: [
            const StoryCategoryList(
              icon: Icons.whatshot_rounded,
              title: 'trending',
              index: 'stories_trending',
            ),
            const StoryCategoryList(
              icon: Icons.thumb_up_rounded,
              title: 'popular',
              index: 'stories',
            ),
            ListTile(
              leading: const Icon(Icons.explore_rounded),
              horizontalTitleGap: 0,
              title: Text(
                'explore'.titleCase,
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: const Icon(Icons.search_rounded),
              onTap: () => showSearchSheet(context),
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
              builder: (context, infos) {
                return Column(
                  children: [
                    for (var info in infos)
                      StoryTile(
                        info,
                        onTap: () => showStorySheet(context, info),
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
