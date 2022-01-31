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
        onTap: () {},
        child: Column(
          children: [
            Image.asset(
              'assets/icon.png',
              fit: BoxFit.cover,
              width: 200,
              height: 90,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
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
          ],
        ),
      ),
    );
  }
}
