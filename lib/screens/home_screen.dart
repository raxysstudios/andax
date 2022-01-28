import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/screens/story_screen.dart';
import 'package:andax/screens/profile_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/widgets/paging_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
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
          : FloatingActionButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoryEditorScreen(),
                ),
              ),
              child: const Icon(Icons.edit_rounded),
            ),
      body: PagingList<StoryInfo>(
        onRequest: getStories,
        builder: (context, info, index) {
          return StoryTile(
            info,
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => StoryScreen(info),
              ),
            ),
          );
        },
      ),
    );
  }
}
