import 'dart:async';

import 'package:andax/models/actor.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/actor_editor_dialog.dart';
import '../widgets/actor_tile.dart';
import 'story.dart';

class ActorsEditorScreen extends StatelessWidget {
  const ActorsEditorScreen(
    this.onSelect, {
    this.selectedId,
    this.scroll,
    this.allowNone = false,
    Key? key,
  }) : super(key: key);

  final FutureOr<void> Function(Actor?, bool isNew) onSelect;
  final String? selectedId;
  final ScrollController? scroll;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Story actors'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showActorEditorDialog(
          context,
        ).then((r) => onSelect(r, true)),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add actor'),
      ),
      body: CustomScrollView(
        controller: scroll,
        slivers: [
          if (allowNone)
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: const Text('None'),
                    onTap: () => onSelect(null, false),
                  ),
                  const Divider(),
                ],
              ),
            ),
          Builder(
            builder: (context) {
              final actors = context
                  .watch<StoryEditorState>()
                  .story
                  .actors
                  .values
                  .toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final actor = actors[index];
                    return ActorTile(
                      actor,
                      onTap: () => onSelect(actor, false),
                      selected: selectedId == actor.id,
                      index: index,
                    );
                  },
                  childCount: actors.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 76,
            ),
          )
        ],
      ),
    );
  }
}
