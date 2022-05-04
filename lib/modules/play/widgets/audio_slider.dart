import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/animator.dart';
import '../utils/audio_controller.dart';

class AudioSlider extends StatefulWidget {
  const AudioSlider(
    this.url, {
    this.collapsible = true,
    this.playerKey,
    Key? key,
  }) : super(key: key);

  final String url;
  final bool collapsible;
  final String? playerKey;

  @override
  State<AudioSlider> createState() => _AudioSliderState();
}

class _AudioSliderState extends State<AudioSlider> {
  bool drag = false;
  int value = 0;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    if (!drag) value = audio.position;
    if (widget.collapsible && audio.key != (widget.playerKey ?? widget.url)) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        constraints: const BoxConstraints(minHeight: 3),
      );
    }
    return slideUp(
      key: Key(audio.key),
      child: Slider(
        value: value < audio.duration ? value.toDouble() : 0,
        max: audio.duration.toDouble(),
        onChanged: (s) => setState(() {
          drag = true;
          value = s.toInt();
        }),
        onChangeEnd: (s) async {
          await audio.seek(s.toInt());
          setState(() {
            drag = false;
          });
        },
      ),
    );
  }
}
