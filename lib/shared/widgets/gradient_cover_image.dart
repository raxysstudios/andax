import 'package:flutter/material.dart';

class GradientCoverImage extends StatelessWidget {
  const GradientCoverImage(
    this.url, {
    this.opacity = 1,
    this.reversed = false,
    this.placeholderSize = 24,
    Key? key,
  }) : super(key: key);

  final String? url;
  final double opacity;
  final bool reversed;
  final double placeholderSize;

  @override
  Widget build(BuildContext context) {
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
      child: url == null
          ? Icon(
              Icons.landscape_rounded,
              size: placeholderSize,
            )
          : Image.network(url!, fit: BoxFit.cover),
    );
  }
}
