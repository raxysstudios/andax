import 'package:flutter/material.dart';

String? emptyValidator(String? value) {
  value = value?.trim() ?? '';
  if (value.isEmpty) return 'Cannot be empty';
  return null;
}

Future<void> showEditorDialog<T>(
  BuildContext context, {
  required ValueGetter<T?> result,
  required ValueSetter<T?> callback,
  required String title,
  required List<Widget> Function(
    BuildContext context,
    void Function(void Function()),
  )
      builder,
  EdgeInsets padding = const EdgeInsets.fromLTRB(24, 20, 24, 24),
}) async {
  final form = GlobalKey<FormState>();
  final theme = Theme.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        contentPadding: padding,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: form,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: builder(context, setState),
                ),
              ),
            );
          },
        ),
        actions: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  callback(null);
                },
                icon: const Icon(Icons.delete_rounded),
                color: theme.colorScheme.error,
                splashColor: theme.colorScheme.error.withOpacity(0.1),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancel'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(theme.hintColor),
                  overlayColor: MaterialStateProperty.all(
                    theme.hintColor.withOpacity(0.1),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (form.currentState?.validate() ?? false) {
                    Navigator.pop(context);
                    callback(result());
                  }
                },
                icon: const Icon(Icons.done_rounded),
                label: const Text('Save'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
