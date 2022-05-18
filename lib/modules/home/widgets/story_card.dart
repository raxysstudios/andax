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
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          children: [
            widget.story.imageUrl.isEmpty
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.history_edu_rounded,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                    ),
                  )
                : Positioned.fill(
                    child: GradientCoverImage(widget.story.imageUrl),
                  ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  widget.story.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
