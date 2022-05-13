import 'package:andax/shared/widgets/options_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';
import '../utils/alert.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final play = context.read<PlayScreenState>();
    final finished = play.storyline.last.transitions.isEmpty;
    final theme = Theme.of(context).colorScheme;
    return Card(
      color: theme.primary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(64),
      ),
      child: OptionsButton(
        [
          OptionItem.simple(Icons.replay_rounded, 'Restart', () {
            if (finished) {
              play.reset();
            } else {
              showProgressAlert(
                context,
                play.reset,
                confirmationIcon: Icons.replay_rounded,
                confirmationText: 'Restart',
              );
            }
          }),
          OptionItem.simple(Icons.exit_to_app_rounded, 'Leave', () {
            if (play.storyline.last.transitions.isEmpty) {
              Navigator.pop(context);
            } else {
              showProgressAlert(
                context,
                () => Navigator.pop(context),
              );
            }
          }),
        ],
        icon: Icon(
          Icons.menu_rounded,
          color: theme.onPrimary,
        ),
      ),
    );
  }
}
