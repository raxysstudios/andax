import 'package:flutter/material.dart';

class LoadingBuilder<T> extends StatelessWidget {
  const LoadingBuilder({
    required this.future,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final Future<T> future;
  final Widget Function(BuildContext, T) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.data == null) {
          return const Text('Error...');
        }
        return builder(context, snapshot.data!);
      },
    );
  }
}
