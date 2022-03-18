import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/cupertino.dart';

void showProgressAlert(
  BuildContext context,
  VoidCallback onAccept,
) async {
  final accept = await showDangerDialog(
    context,
    'You progress will be lost!',
    confirmText: 'Leave',
    rejectText: 'Stay',
  );
  if (accept) onAccept();
}
