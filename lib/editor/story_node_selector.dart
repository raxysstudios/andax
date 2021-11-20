import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';

import 'story_editor_screen.dart';

class StoryNodeSelector extends StatelessWidget {
  const StoryNodeSelector(
    this.value,
    this.onChanged, {
    allowNone = true,
    Key? key,
  }) : super(key: key);

  final Node? value;
  final ValueSetter<Node?> onChanged;
  final bool allowNone = true;

  @override
  Widget build(BuildContext context) {
    final editor = context.read<StoryEditorState>();
    return DropdownButton<Node>(
      icon: const SizedBox(),
      underline: const SizedBox(),
      value: value,
      onChanged: onChanged,
      items: [
        if (allowNone)
          const DropdownMenuItem<Node>(
            child: Text("None"),
          ),
        for (final node in editor.story.nodes.values)
          DropdownMenuItem(
            value: node,
            child: Text(
              MessageTranslation.get(editor.translation, node.id)?.text ?? '',
            ),
          ),
      ],
    );
  }
}
