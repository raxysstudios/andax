import 'package:andax/models/story.dart';
import 'package:andax/shared/widgets/paging_list.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:andax/store.dart';
import 'package:flutter/material.dart';

Future<List<StoryInfo>> _getTranslations(
  int page,
  String storyId,
) async {
  final hits = await algolia.instance
      .index('stories')
      .query('')
      .filters('storyID:$storyId')
      .setPage(page)
      .getObjects()
      .then((r) => r.hits);
  return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
}

Future<StoryInfo?> showTranslationSelector(
  BuildContext context,
  StoryInfo target,
) {
  return showScrollableModalSheet<StoryInfo>(
    context: context,
    builder: (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Select translation to edit'),
        ),
        body: PagingList<StoryInfo>(
          onRequest: (i, s) => _getTranslations(i, target.storyID),
          builder: (context, item, index) {
            return ListTile(
              title: Text(item.title),
              subtitle: Text(item.language),
              trailing:
                  item == target ? const Icon(Icons.assignment_rounded) : null,
              onTap: item == target ? null : () => Navigator.pop(context, item),
            );
          },
        ),
      );
    },
  );
}
