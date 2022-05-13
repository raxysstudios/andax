import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    this.onTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const steps = 4;
    const italic = TextStyle(fontStyle: FontStyle.italic);
    return ListTile(
      title: LoopAnimation<double>(
        tween: Tween(begin: 0, end: steps - 1),
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 900),
        builder: (context, child, tween) {
          final j = tween.round();
          return Text(
            'Typing' + '.' * j,
            style: italic,
          );
        },
      ),
      subtitle: const Text(
        'Tap to skip',
        style: italic,
      ),
      onTap: onTap,
    );
  }
}
