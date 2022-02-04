import 'package:andax/models/story.dart';
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
            if (widget.story.imageUrl != null)
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [
                          0,
                          .75,
                          1,
                        ]).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    widget.story.imageUrl!,
                    fit: BoxFit.cover,
                  ),
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
