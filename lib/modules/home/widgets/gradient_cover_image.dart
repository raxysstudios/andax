import 'package:flutter/material.dart';

class GradientCoverImage extends StatelessWidget {
  const GradientCoverImage(
    this.url, {
    this.opacity = 1,
    this.reversed = false,
    this.border = 0,
    Key? key,
  }) : super(key: key);

  final String url;
  final double opacity;
  final bool reversed;
  final double border;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.transparent,
      Colors.black.withOpacity(opacity),
    ];

    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: reversed ? colors.reversed.toList() : colors,
          stops: [
            0,
            (reversed ? 1 - border : border),
          ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}
