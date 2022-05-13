import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/material.dart';

void showProgressAlert(
  BuildContext context,
  VoidCallback onAccept, {
  IconData confirmationIcon = Icons.exit_to_app_rounded,
  String confirmationText = 'Leave',
}) async {
  final accept = await showDangerDialog(
    context,
    'You progress will be lost!',
    confirmIcon: confirmationIcon,
    confirmText: confirmationText,
    rejectIcon: Icons.play_arrow_rounded,
    rejectText: 'Stay',
  );
  if (accept) onAccept();
}
