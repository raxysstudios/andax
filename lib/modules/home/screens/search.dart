import 'package:andax/models/story.dart';
import 'package:andax/modules/home/services/stories.dart';
import 'package:andax/modules/story_info/screens/story_info.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/story_tile.dart';
import 'package:andax/store.dart';
import 'package:flutter/material.dart';

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
  var languages = <String>[];
  var language = '';

  var sorts = [
    _SortMode('stories', 'likes', Icons.favorite_rounded),
    _SortMode('stories', 'views', Icons.visibility_rounded),
    _SortMode('stories_updated', 'new', Icons.new_releases_rounded),
  ];
  late var sort = sorts.first;

  @override
  void initState() {
    super.initState();
    algolia.index('stories').facetQuery('language', maxFacetHits: 100).then(
          (fs) => setState(() {
            languages = fs.map((h) => h.value).toList();
            if (languages.isNotEmpty) language = languages.first;
          }),
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
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Row(
            children: [
              PopupMenuButton<_SortMode>(
                child: Chip(
                  avatar: Icon(sort.icon),
                  label: Text('Sort by ${sort.text.titleCase}'),
                ),
                onSelected: (s) => setState(() {
                  sort = s;
                }),
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
              PopupMenuButton<String>(
                child: Chip(
                  avatar: const Icon(Icons.language_rounded),
                  label: Text('Language: $language'),
                ),
                onSelected: (l) => setState(() {
                  language = l;
                }),
                itemBuilder: (context) {
                  return [
                    for (final language in languages)
                      PopupMenuItem(
                        value: language,
                        child: Text(language),
                      ),
                  ];
                },
              )
            ],
          ),
        ),
      ),
      body: PagingList<StoryInfo>(
        onRequest: (p, l) => getStories(sort.index, page: p),
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
