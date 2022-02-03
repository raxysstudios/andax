import 'package:andax/get_stories.dart';
import 'package:andax/models/story.dart';
import 'package:andax/modules/story_info/screens/story_info.dart';
import 'package:andax/widgets/paging_list.dart';
import 'package:andax/widgets/story_tile.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
        title: const Text('Search'),
      ),
      body: PagingList<StoryInfo>(
        onRequest: (p, l) => getStories('stories_updated', page: p),
        builder: (context, info, index) {
          return StoryTile(
            info,
            onTap: () => openStory(info),
          );
        },
      ),
    );
  }
}
