import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Displays a dialog that allows the user to change their display name.
///
/// Returns `null` if the user cancelled the operation, or the new name instead.
Future<String?> promptDisplayNameChange(BuildContext context, User user) async {
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
    return name;
  }
  return null;
}
