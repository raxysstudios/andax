import 'package:andax/models/story.dart';
import 'package:andax/utils.dart';
import 'package:andax/widgets/span_icon.dart';
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
      subtitle: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: Theme.of(context).textTheme.caption?.copyWith(
                fontSize: 14,
              ),
          children: [
            const WidgetSpan(
              child: SpanIcon(
                Icons.visibility_outlined,
              ),
            ),
            TextSpan(text: info.views.toString()),
            const WidgetSpan(
              child: SpanIcon(
                Icons.favorite_rounded,
                padding: EdgeInsets.only(left: 4, right: 2),
              ),
            ),
            TextSpan(text: info.likes.toString()),
            const WidgetSpan(
              child: SpanIcon(
                Icons.tag_rounded,
                padding: EdgeInsets.only(left: 4, right: 2),
              ),
            ),
            TextSpan(text: prettyTags(info.tags)!),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
