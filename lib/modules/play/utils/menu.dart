import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/modules/play/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showPlayMenu(BuildContext context) async {
  final play = context.read<PlayScreenState>();
  final finished = play.storyline.last.transitions.isEmpty;
  final exit = await showDialog<bool>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(play.tr.title),
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow_rounded),
            title: const Text('Resume'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.replay_rounded),
            title: const Text('Restart'),
            onTap: () {
              Navigator.pop(context);
              if (finished) {
                play.reset();
              } else {
                showProgressAlert(context, play.reset);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.close_rounded),
            title: const Text('Exit'),
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );
  if (exit != null && exit) {
    if (play.storyline.last.transitions.isEmpty) {
      Navigator.pop(context);
    } else {
      showProgressAlert(
        context,
        () => Navigator.pop(context),
      );
    }
  }
}
