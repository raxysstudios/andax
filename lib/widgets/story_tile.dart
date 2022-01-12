import 'package:andax/models/story.dart';
import 'package:andax/utils.dart';
import 'package:flutter/material.dart';

class StoryTile extends StatelessWidget {
  const StoryTile(
    this.info, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  final StoryInfo info;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(info.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.description == null) Text(info.description!),
          if (info.tags != null)
            Row(
              children: [
                const Icon(
                  Icons.tag_rounded,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(prettyTags(info.tags)!),
              ],
            ),
        ],
      ),
      trailing: Chip(
        avatar: const Icon(
          Icons.favorite_rounded,
          size: 16,
        ),
        label: Text(info.likes.toString()),
      ),
      onTap: onTap,
    );
  }
}
