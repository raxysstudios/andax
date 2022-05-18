import 'package:algolia/algolia.dart' show AlgoliaError;
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
          final error = snapshot.error;
          if (error is AlgoliaError) {
            return Text('Error: ${error.error}');
          }
          return const Text('An unknown error occurred');
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}
