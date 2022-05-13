import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> editDisplayName(BuildContext context, User user) async {
  final form = GlobalKey<FormState>();
  var name = '';
  final save = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Change displayed name'),
        content: Form(
          key: form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            onChanged: (s) => name = s.trim(),
            initialValue: user.displayName,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () {
              if (form.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
        ],
      );
    },
  );
  if (save ?? false) {
    await showLoadingDialog(
      context,
      user.updateDisplayName(name),
    );
  }
}
