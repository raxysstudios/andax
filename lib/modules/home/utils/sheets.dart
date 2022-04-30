import 'package:andax/models/story.dart';
import 'package:andax/modules/home/screens/search.dart';
import 'package:andax/modules/home/screens/story.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:andax/shared/widgets/story_tile.dart';
import 'package:flutter/material.dart';

import '../services/searching.dart';

Future<void> showStorySheet(BuildContext context, StoryInfo info) async {
  await showScrollableModalSheet<void>(
    context: context,
    builder: (context, scroll) {
      return StoryScreen(
        info,
        scroll: scroll,
      );
    },
  );
}

Future<void> showSearchSheet(BuildContext context) async {
  await showScrollableModalSheet<void>(
    context: context,
    builder: (context, scroll) {
      return const SearchScreen();
    },
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
