import 'package:andax/models/node.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/modal_picker.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

SliverList buildNodesSliverList(
  StoryEditorState editor,
  ValueSetter<Node> onSelected, [
  String? selectedId,
]) {
  final nodes = editor.story.nodes.values.toList();
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final node = nodes[index];
        return ListTile(
          onTap: () => onSelected(node),
          title: Text(
            MessageTranslation.getText(
              editor.translation,
              node.id,
            ),
          ),
          trailing: Text(
            (nodes.indexOf(node) + 1).toString(),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          selected: node.id == selectedId,
        );
      },
      childCount: nodes.length,
    ),
  );
}

Future<Node?> showStoryNodePickerSheet(
  BuildContext context, [
  String? selectedId,
]) {
  final editor = context.read<StoryEditorState>();
  return showModalPicker(context, [
    const SliverAppBar(
      leading: RoundedBackButton(),
      title: Text('Pick Node'),
      forceElevated: true,
      floating: true,
      snap: true,
      pinned: true,
    ),
    buildNodesSliverList(
      editor,
      (node) => Navigator.pop(context, node),
      selectedId,
    ),
  ]);
}
