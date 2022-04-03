import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

Widget slideUp({required Widget child, Key? key}) {
  return PlayAnimation<double>(
    key: key,
    tween: Tween(begin: 0, end: 1),
    curve: Curves.easeInOutQuad,
    duration: const Duration(milliseconds: 200),
    child: child,
    builder: (context, child, tween) {
      return Opacity(
        opacity: tween,
        child: Transform.translate(
          offset: Offset(0, 32 * (1 - tween)),
          child: child,
        ),
      );
    },
  );
}
