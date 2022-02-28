import 'package:flutter/material.dart';

class GradientCoverImage extends StatelessWidget {
  const GradientCoverImage(
    this.url, {
    this.opacity = 1,
    this.reversed = false,
    Key? key,
  }) : super(key: key);

  final String? url;
  final double opacity;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    if (url == null) return const SizedBox();
    final colors = [
      Colors.black.withOpacity(opacity),
      Colors.transparent,
      Colors.transparent,
    ];

    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: reversed ? colors.reversed.toList() : colors,
          stops: [
            0,
            reversed ? .25 : .75,
            1,
          ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Image.network(url!, fit: BoxFit.cover),
    );
  }
}
