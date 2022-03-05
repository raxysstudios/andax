import 'package:flutter/material.dart';

Future<bool> showDangerDialog(
  BuildContext context,
  String title, {
  String confirmText = 'Delete',
  String rejectText = 'Keep',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.delete_rounded),
            label: Text(confirmText),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(theme.error),
              overlayColor: MaterialStateProperty.all(
                theme.error.withOpacity(0.1),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.edit_rounded),
            label: Text(rejectText),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
