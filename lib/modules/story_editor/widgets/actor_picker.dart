import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/widgets/modal_picker.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';

import '../screens/narrative_editor.dart';

Future<Actor?> showActorPickerSheet(
  StoryEditorState editor,
  BuildContext context, [
  String? selectedId,
]) {
  final actors = editor.story.actors.values.toList();
  return showModalPicker(
    context,
    (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          title: const Text('Pick Actor'),
        ),
        body: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  leading: const Icon(Icons.cancel_rounded),
                  title: const Text('None'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final actor = actors[index];
                  return ListTile(
                    onTap: () => Navigator.pop(context, actor),
                    leading: Icon(actor.type == ActorType.npc
                        ? Icons.smart_toy_rounded
                        : Icons.face_rounded),
                    title: Text(
                      ActorTranslation.getName(
                        editor.translation,
                        actor.id,
                      ),
                    ),
                    trailing: Text(
                      '#${(actors.indexOf(actor) + 1)}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
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
