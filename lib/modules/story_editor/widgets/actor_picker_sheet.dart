import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/actor_tile.dart';
import 'package:andax/shared/widgets/modal_picker.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'actor_editor_dialog.dart';

void showActorPickerSheet(
  BuildContext context,
  StoryEditorState editor,
  ValueSetter<Actor?> onSelect, [
  String? selectedId,
]) {
  final actors = editor.story.actors.values.toList();
  showModalPicker<Actor>(
    context,
    (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Pick actor'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showActorEditorDialog(
            context,
            editor,
            (r) {
              if (r != null) {
                Navigator.pop(context);
                onSelect(r);
              }
            },
          ),
          tooltip: 'Add actor',
          child: const Icon(Icons.person_add_rounded),
        ),
        body: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('None'),
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(null);
                  },
                ),
                const Divider(),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final actor = actors[index];
                  return ActorTile(
                    actor,
                    editor,
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(actor);
                    },
                    index: index,
                    selected: actor.id == selectedId,
                  );
                },
                childCount: actors.length,
              ),
            ),
          ],
        ),
      );
    },
  );
}
