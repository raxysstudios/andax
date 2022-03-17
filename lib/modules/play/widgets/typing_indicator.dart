import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MirrorAnimation<double>(
        tween: Tween(begin: 0, end: 1),
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 900),
        builder: (context, child, tween) {
          var text = '';
          for (var i = 1; i < 4; i++) {
            if (tween > .3 * i) text += ' •';
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text),
          );
        },
      ),
    );
  }
}
