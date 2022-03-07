import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context, [
  IconData icon = Icons.error_outline_outlined,
  String text = 'Error!',
]) {
  final theme = Theme.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.colorScheme.surface,
      content: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(
            text,
            style: theme.textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    ),
  );
}
