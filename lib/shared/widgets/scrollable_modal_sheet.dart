import 'dart:math';

import 'package:flutter/material.dart';

Future<T?> showScrollableModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController) builder,
  double? minSize,
}) {
  final media = MediaQuery.of(context);
  final maxSize = 1 - (kToolbarHeight + media.padding.top) / media.size.height;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        minChildSize: max((minSize ?? maxSize) - .1, .1),
        initialChildSize: minSize ?? maxSize,
        maxChildSize: maxSize,
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
