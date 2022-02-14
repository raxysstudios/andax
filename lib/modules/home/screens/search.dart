import 'package:algolia/algolia.dart';
import 'package:andax/models/story.dart';
import 'package:andax/modules/home/services/stories.dart';
import 'package:andax/modules/story_info/screens/story_info.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/story_tile.dart';
import 'package:andax/store.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SortMode {
  final String index;
  final String text;
  final IconData icon;

  _SortMode(this.index, this.text, this.icon);
}

class _SearchScreenState extends State<SearchScreen> {
  final textController = TextEditingController();
  final pagingController = PagingController<int, StoryInfo>(firstPageKey: 0);
  late AlgoliaQuery query;

  var sorts = [
    _SortMode('stories', 'likes', Icons.favorite_rounded),
    _SortMode('stories_views', 'views', Icons.visibility_rounded),
    _SortMode('stories_updated', 'new', Icons.new_releases_rounded),
  ];
  late var sort = sorts.first;

  @override
  void initState() {
    super.initState();
    textController.addListener(updateQuery);
    updateQuery();
  }

  Future<void> openStory(StoryInfo info) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(info),
      ),
    );
  }

  void updateQuery() {
    setState(() {
      query = algolia.index(sort.index).query(textController.text);
      pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration.collapsed(
            hintText: 'Search',
          ),
        ),
        actions: [
          if (textController.text.isNotEmpty)
            IconButton(
              onPressed: textController.clear,
              icon: const Icon(Icons.clear_rounded),
            ),
          Badge(
            ignorePointer: true,
            animationType: BadgeAnimationType.fade,
            position: BadgePosition.topEnd(top: 0, end: 0),
            badgeColor: Theme.of(context).colorScheme.primary,
            badgeContent: Icon(sort.icon, size: 16),
            child: PopupMenuButton<_SortMode>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: (s) {
                sort = s;
                updateQuery();
              },
              itemBuilder: (context) {
                return [
                  for (final sort in sorts)
                    PopupMenuItem(
                      value: sort,
                      child: ListTile(
                        leading: Icon(sort.icon),
                        title: Text(sort.text.titleCase),
                      ),
                    ),
                ];
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PagingList<StoryInfo>(
        controller: pagingController,
        onRequest: (p, l) async {
          final qs = await query.setPage(p).getObjects();
          return storiesFromSnapshot(qs);
        },
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
