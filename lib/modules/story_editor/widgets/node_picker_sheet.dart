import 'package:andax/models/node.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/shared/widgets/modal_picker.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';

import 'narrative_list_view.dart';

Future<Node?> showNodePickerSheet(
  BuildContext context,
  StoryEditorState editor, [
  String? selectedId,
]) {
  return showModalPicker(
    context,
    (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Pick Node'),
        ),
        body: NarrativeListView(
          editor,
          onSelected: (node) => Navigator.pop(context, node),
          selectedId: selectedId,
          interactive: false,
        ),
      );
    },
  );
}
