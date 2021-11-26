import 'package:flutter/material.dart';

class MaybePopAlert extends StatelessWidget {
  const MaybePopAlert(
    this.child, {
    this.title = 'Exit?',
    Key? key,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Exit'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Stay'),
                ),
              ],
            );
          },
        );
        return result ?? false;
      },
      child: child,
    );
  }
}
