import 'package:andax/models/story.dart';
import 'package:andax/modules/home/screens/search.dart';
import 'package:andax/modules/home/screens/story.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showStorySheet(BuildContext context, StoryInfo info) async {
  await showScrollableModalSheet<void>(
    context: context,
    minSize: .6,
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
