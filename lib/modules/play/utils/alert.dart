import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/material.dart';

void showProgressAlert(
  BuildContext context,
  VoidCallback onAccept,
) async {
  final accept = await showDangerDialog(
    context,
    'You progress will be lost!',
    confirmIcon: Icons.exit_to_app_rounded,
    confirmText: 'Leave',
    rejectIcon: Icons.play_arrow_rounded,
    rejectText: 'Stay',
  );
  if (accept) onAccept();
}
