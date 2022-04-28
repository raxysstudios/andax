import 'package:andax/models/story.dart';
import 'package:andax/modules/home/utils/sheets.dart';
import 'package:andax/modules/home/widgets/story_tile.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/profile.dart';
import 'user_stats.dart';

Future<void> showLikedStories(BuildContext context, User user) {
  return showScrollableModalSheet<void>(
    context: context,
    builder: (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Liked stories'),
        ),
        body: StatefulBuilder(
          builder: (context, setState) {
            return PagingList<LikeItem>(
              scroll: scroll,
              onRequest: (i, s) => getLikes(user, i, s),
              builder: (context, item, index) {
                return StoryTile(
                  item.value,
                  onTap: () => showStorySheet(context, item.value),
                );
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> showGenericStoriesList(
  BuildContext context,
  String title,
  Future<List<StoryInfo>> Function(int page, StoryInfo? last) getter,
) {
  return showScrollableModalSheet<void>(
    context: context,
    builder: (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Liked stories'),
        ),
        body: StatefulBuilder(
          builder: (context, setState) {
            return PagingList<StoryInfo>(
              scroll: scroll,
              onRequest: getter,
              builder: (context, info, index) {
                return StoryTile(
                  info,
                  onTap: () => showStorySheet(context, info),
                );
              },
            );
          },
        ),
      );
    },
  );
}
