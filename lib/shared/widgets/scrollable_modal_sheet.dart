import 'package:flutter/material.dart';

Future<T?> showScrollableModalSheet<T>({
  required BuildContext context,
  required ScrollableWidgetBuilder builder,
}) async {
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
        builder: (context, scroll) {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: builder(context, scroll),
            ),
          );
        },
      );
    },
  );
}
