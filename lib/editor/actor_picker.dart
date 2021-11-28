import 'package:andax/models/actor.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/modal_picker.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

Future<Actor?> showActorPickerSheet(
  BuildContext context, [
  String? selectedId,
]) {
  final editor = context.read<StoryEditorState>();
  final actors = editor.story.actors.values.toList();
  return showModalPicker(context, [
    const SliverAppBar(
      leading: RoundedBackButton(),
      title: Text('Pick Actor'),
      forceElevated: true,
      floating: true,
      snap: true,
      pinned: true,
    ),
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
  ]);
}
