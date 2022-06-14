import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:andax/models/story.dart';
import 'package:andax/modules/home/services/searching.dart';
import 'package:andax/modules/home/utils/sheets.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/story_tile.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    this.scroll,
    Key? key,
  }) : super(key: key);

  final ScrollController? scroll;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SortMode {
  final String index;
  final String text;
  final IconData icon;

  const _SortMode(this.index, this.text, this.icon);
}

class _SearchScreenState extends State<SearchScreen> {
  final textController = TextEditingController();
  final pagingController = PagingController<int, StoryInfo>(firstPageKey: 0);
  late AlgoliaQuery query;
  var timer = Timer(Duration.zero, () {});

  static const sorts = [
    _SortMode('stories', 'likes', Icons.favorite_rounded),
    _SortMode('stories_views', 'views', Icons.visibility_rounded),
    _SortMode('stories_updated', 'new', Icons.new_releases_rounded),
  ];
  late var sort = sorts.first;

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      timer.cancel();
      timer = Timer(
        const Duration(milliseconds: 300),
        updateQuery,
      );
      setState(() {});
    });
    updateQuery();
  }

  void updateQuery() {
    timer.cancel();
    setState(() {
      query = formQuery(sort.index, textController.text);
      pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Type title, description, tags',
            border: InputBorder.none,
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
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Sort by',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                for (final s in sorts)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InputChip(
                      avatar: Icon(s.icon),
                      label: Text(s.text),
                      selected: sort == s,
                      onSelected: (t) {
                        if (t) {
                          sort = s;
                          updateQuery();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: PagingList<StoryInfo>(
        scroll: widget.scroll,
        controller: pagingController,
        onRequest: (p, l) async {
          final qs = await query.setPage(p).getObjects();
          return storiesFromSnapshot(qs);
        },
        builder: (context, info, index) {
          return StoryTile(
            info,
            onTap: () => showStorySheet(context, info),
          );
        },
      ),
    );
  }
}
