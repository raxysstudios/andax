import 'package:andax/models/story.dart';
import 'package:andax/modules/home/utils/sheets.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/loading_builder.dart';
import 'package:flutter/material.dart';

import 'story_card.dart';

class StoriesShelf extends StatelessWidget {
  const StoriesShelf({
    required this.icon,
    required this.title,
    required this.stories,
    this.trailing = const Icon(Icons.arrow_forward_rounded),
    this.onTitleTap,
    Key? key,
  }) : super(key: key);

  final Widget? trailing;
  final VoidCallback? onTitleTap;
  final IconData icon;
  final String title;
  final Future<List<StoryInfo>> stories;

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
          trailing: trailing,
          onTap: onTitleTap,
        ),
        LoadingBuilder<List<StoryInfo>>(
          future: stories,
          builder: (context, infos) {
            if (infos.isEmpty) return const SizedBox();
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
}
