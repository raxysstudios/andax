import 'package:andax/models/actor.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_editor/widgets/actor_tile.dart';
import 'package:andax/shared/widgets/modal_picker.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'actor_editor_dialog.dart';

void showActorPickerSheet(
  BuildContext context,
  ValueSetter<Actor?> onSelect, [
  String? selectedId,
]) {
  final editor = context.read<StoryEditorState>();
  showModalPicker<Actor>(
    context,
    (context, scroll) {
      final actors = editor.story.actors.values.toList();
      return Provider.value(
        value: editor,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                leading: const RoundedBackButton(),
                title: const Text('Pick actor'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => showActorEditorDialog(context).then((r) {
                  if (r != null) {
                    Navigator.pop(context);
                    onSelect(r);
                  }
                }),
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
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 76),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final actor = actors[index];
                          return ActorTile(
                            actor,
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
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
