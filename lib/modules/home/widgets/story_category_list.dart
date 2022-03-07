import 'package:andax/models/story.dart';
import 'package:andax/modules/home/services/searching.dart';
import 'package:andax/modules/home/services/sheets.dart';
import 'package:andax/modules/home/widgets/story_tile.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/loading_builder.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/material.dart';

import 'story_card.dart';

class StoryCategoryList extends StatelessWidget {
  const StoryCategoryList({
    required this.icon,
    required this.title,
    required this.index,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          horizontalTitleGap: 0,
          title: Text(
            title.titleCase,
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => showCategorySheet(context, title, index),
        ),
        LoadingBuilder<List<StoryInfo>>(
          future: getStories(index, hitsPerPage: 10),
          builder: (context, infos) {
            return SizedBox(
              height: 128,
              child: ListView.builder(
                itemExtent: 200,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: infos.length,
                itemBuilder: (context, index) {
                  final info = infos[index];
                  return StoryCard(
                    info,
                    onTap: () => showStorySheet(context, info),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> showCategorySheet(
    BuildContext context,
    String title,
    String index,
  ) async {
    await showScrollableModalSheet<void>(
      context: context,
      builder: (context, scroll) {
        return Scaffold(
          appBar: AppBar(
            leading: const RoundedBackButton(),
            title: Text(title.titleCase),
            actions: [
              IconButton(
                onPressed: () => showSearchSheet(context),
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
                onTap: () => showStorySheet(context, info),
              );
            },
          ),
        );
      },
    );
  }
}
