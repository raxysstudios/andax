import 'package:andax/shared/widgets/markdown_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageCard extends StatelessWidget {
  const MessageCard(
    this.text, {
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: MarkdownText(text),
        ),
      ),
    );
  }
}
