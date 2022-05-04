import 'package:andax/models/transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';

class TransitionsChips extends StatelessWidget {
  const TransitionsChips({
    required this.transitions,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final List<Transition> transitions;
  final ValueSetter<Transition> onTap;

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Wrap(
        spacing: 8,
        children: [
          for (final transition in transitions)
            InputChip(
              elevation: 1,
              onPressed: () => onTap(transition),
              label: Text(play.tr.transition(transition)),
            ),
        ],
      ),
    );
  }
}
