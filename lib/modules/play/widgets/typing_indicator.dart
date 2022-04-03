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
    const l = 5;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InputChip(
        onPressed: onTap,
        elevation: 1,
        label: MirrorAnimation<double>(
          tween: Tween(begin: 0, end: l - 1),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 900),
          builder: (context, child, tween) {
            final j = tween.round();
            return Text(
              Iterable.generate(
                l,
                (i) => i == j ? '•' : ' ',
              ).join(' '),
            );
          },
        ),
      ),
    );
  }
}
