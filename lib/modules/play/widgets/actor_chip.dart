import 'package:andax/models/actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';

class ActorChip extends StatelessWidget {
  const ActorChip(
    this.actor, {
    Key? key,
  }) : super(key: key);

  final Actor actor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Chip(
          avatar: actor.avatarUrl == null
              ? null
              : CircleAvatar(
                  foregroundImage: NetworkImage(actor.avatarUrl!),
                  backgroundColor: Colors.transparent,
                ),
          label: Text(
            context.watch<PlayScreenState>().tr.actor(actor),
          ),
          labelStyle: TextStyle(
            color: actor.type == ActorType.player
                ? theme.colorScheme.primary
                : null,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
