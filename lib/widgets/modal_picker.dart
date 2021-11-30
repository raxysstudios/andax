import 'package:flutter/material.dart';

Future<T?> showModalPicker<T>(
  BuildContext context,
  Function(BuildContext, ScrollController) builder,
) {
  final media = MediaQuery.of(context);
  final childSize =
      1 - (kToolbarHeight + media.padding.top) / media.size.height;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        minChildSize: childSize - .1,
        initialChildSize: childSize,
        maxChildSize: childSize,
        builder: (context, controller) {
          return Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            clipBehavior: Clip.antiAlias,
            child: builder(context, controller),
          );
        },
      );
    },
  );
}
