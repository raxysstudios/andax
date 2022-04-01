import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/modules/play/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showPlayMenu(BuildContext context) async {
  final play = context.read<PlayScreenState>();
  final exit = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: Text(
                  play.tr.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: const Text('Playing now'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.replay_rounded),
                title: const Text('Restart'),
                onTap: () {
                  Navigator.pop(context);
                  showProgressAlert(context, play.reset);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Exit'),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (exit != null && exit) {
    showProgressAlert(
      context,
      () => Navigator.pop(context),
    );
  }
}
