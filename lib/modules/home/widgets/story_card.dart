import 'package:andax/models/story.dart';
import 'package:andax/modules/home/widgets/gradient_cover_image.dart';
import 'package:flutter/material.dart';

class StoryCard extends StatefulWidget {
  const StoryCard(
    this.story, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  final StoryInfo story;
  final VoidCallback? onTap;

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.story.imageUrl == null
                  ? Icon(
                      Icons.history_edu_rounded,
                      size: 48,
                      color: Theme.of(context).textTheme.caption?.color,
                    )
                  : GradientCoverImage(
                      widget.story.imageUrl!,
                      reversed: true,
                    ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
