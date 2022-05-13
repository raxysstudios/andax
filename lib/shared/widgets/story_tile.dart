import 'package:andax/models/story.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/span_icon.dart';
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
      leading: AspectRatio(
        aspectRatio: 1,
        child: Card(
          margin: EdgeInsets.zero,
          child: info.imageUrl.isEmpty
              ? const Icon(Icons.history_edu_rounded)
              : Image.network(
                  info.imageUrl,
                  fit: BoxFit.cover,
                ),
        ),
      ),
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
                Icons.visibility_rounded,
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
            if (info.tags.isNotEmpty) ...[
              const WidgetSpan(
                child: SpanIcon(
                  Icons.tag_rounded,
                  padding: EdgeInsets.only(left: 4, right: 2),
                ),
              ),
              TextSpan(text: info.tags.first),
            ],
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
