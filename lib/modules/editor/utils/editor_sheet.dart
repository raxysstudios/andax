import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/material.dart';

String? emptyValidator(String? value) {
  value = value?.trim() ?? '';
  if (value.isEmpty) return 'Cannot be empty';
  return null;
}

Widget buildExplanationTile(
  BuildContext context,
  String title, [
  String? subtitle,
]) {
  final theme = Theme.of(context).textTheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: theme.bodyText1,
        ),
      ),
      if (subtitle != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            subtitle,
            style: theme.bodyText2,
          ),
        ),
      const SizedBox(height: 4),
    ],
  );
}

Future<T?> showEditorSheet<T>({
  required BuildContext context,
  required String title,
  T? initial,
  required ValueGetter<T> onSave,
  VoidCallback? onDelete,
  required List<Widget> Function(
    BuildContext context,
    void Function(void Function()),
  )
      builder,
}) async {
  final form = GlobalKey<FormState>();
  final keep = await showScrollableModalSheet<bool>(
    context: context,
    builder: (context, scroll) {
      return WillPopScope(
        onWillPop: () => showDangerDialog(
          context,
          'Discard usaved edits?',
          confirmText: 'Discard',
          rejectText: 'Stay',
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: const RoundedBackButton(),
            title: Text(title),
            actions: [
              if (onDelete != null)
                IconButton(
                  onPressed: () async {
                    if (await showDangerDialog(
                      context,
                      'Delete the object?',
                      confirmText: 'Delete',
                      rejectText: 'Keep',
                    )) {
                      onDelete();
                      Navigator.pop(context, false);
                    }
                  },
                  icon: const Icon(Icons.delete_rounded),
                ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (form.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Icon(Icons.done_all_rounded),
            tooltip: 'Save',
          ),
          body: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: form,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.only(bottom: 76),
                  children: builder(context, setState),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  if (keep == null) return initial;
  if (keep) return onSave();
  return null;
}
