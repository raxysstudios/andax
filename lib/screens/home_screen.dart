import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/screens/story_screen.dart';
import 'package:andax/screens/settings_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/story.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );
  List<StoryInfo> scenarios = [];

  Future<void> refreshScenarios() async {
    final scenarios = await algolia.instance
        .index('stories')
        .query('')
        // .filters('language:${settings.targetLanguage}')
        .getObjects()
        .then(
          (s) => s.hits.map(
            (h) => StoryInfo.fromAlgoliaHit(h),
          ),
        );
    setState(
      () => this.scenarios
        ..clear()
        ..addAll(scenarios),
    );
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.settings_rounded),
          ),
          const SizedBox(width: 8),
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
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              header: const MaterialClassicHeader(
                color: Colors.blue,
              ),
              controller: refreshController,
              onRefresh: refreshScenarios,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 76),
                children: [
                  for (final info in scenarios)
                    ListTile(
                      title: Text(info.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info.description == null) Text(info.description!),
                          if (info.tags != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.tag_rounded,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(prettyTags(info.tags)!),
                              ],
                            ),
                        ],
                      ),
                      trailing: Chip(
                        avatar: const Icon(
                          Icons.favorite_rounded,
                          size: 16,
                        ),
                        label: Text(info.likes.toString()),
                      ),
                      onTap: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryScreen(info),
                          ),
                        );
                        await refreshScenarios();
                        refreshController.refreshCompleted();
                        setState(() {});
                      },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
