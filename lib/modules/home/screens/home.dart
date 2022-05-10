import 'package:andax/models/story.dart';
import 'package:andax/modules/editor/screens/story.dart';
import 'package:andax/modules/home/utils/auth.dart';
import 'package:andax/modules/home/widgets/raxys_button.dart';
import 'package:andax/modules/profile/screens/auth_gate.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/story_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/searching.dart';
import '../utils/sheets.dart';
import '../widgets/stories_shelf.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get user => FirebaseAuth.instance.currentUser;
  final scroll = ScrollController();

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
        leading: const RaxysButton(),
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
            icon: Icon(
              user == null ? Icons.login_rounded : Icons.person_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ensureSignIn(
          context,
          () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => const StoryEditorScreen(),
            ),
          ).then((_) => setState(() {})),
          'Sign in to create a story',
        ),
        icon: const Icon(Icons.create_rounded),
        label: const Text('Create'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 76),
        controller: scroll,
        child: Column(
          children: [
            StoriesShelf(
              icon: Icons.whatshot_rounded,
              title: 'trending',
              stories: getStories('stories_trending', hitsPerPage: 10),
              onTitleTap: () => showCategorySheet(
                context,
                'trending',
                'stories_trending',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.explore_rounded),
              horizontalTitleGap: 0,
              title: Text(
                'explore'.titleCase,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            PagingList<StoryInfo>(
              onRequest: (p, l) => getStories('stories_explore', page: p),
              maxPages: 5,
              scroll: scroll,
              builder: (context, info, index) {
                return StoryTile(
                  info,
                  onTap: () => showStorySheet(context, info),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
