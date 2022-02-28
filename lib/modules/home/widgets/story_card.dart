import 'package:andax/models/story.dart';
import 'package:andax/shared/widgets/gradient_cover_image.dart';
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
              child: GradientCoverImage(
                widget.story.imageUrl,
                placeholderSize: 64,
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
                        fontSize: 18,
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
