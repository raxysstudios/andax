import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/material.dart';

String? emptyValidator(String? value) {
  value = value?.trim() ?? '';
  if (value.isEmpty) return 'Cannot be empty';
  return null;
}

Future<bool?> showEditorSheet({
  required BuildContext context,
  required String title,
  VoidCallback? onDelete,
  required List<Widget> Function(
    BuildContext context,
    void Function(void Function()),
  )
      builder,
}) async {
  final form = GlobalKey<FormState>();
  return showScrollableModalSheet<bool>(
    context: context,
    builder: (context, scroll) {
      return WillPopScope(
        onWillPop: () => showDangerDialog(
          context,
          'Discard usaved edits?',
          confirmText: 'Exit',
          rejectText: 'Stay',
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: const RoundedBackButton(),
            title: Text(title),
            actions: [
              if (onDelete != null)
                IconButton(
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context, false);
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
            child: const Icon(Icons.check_circle_outline_rounded),
            tooltip: 'Save',
          ),
          body: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: form,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
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
}
