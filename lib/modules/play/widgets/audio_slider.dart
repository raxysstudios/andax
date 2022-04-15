import 'package:andax/models/node.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/animator.dart';
import '../utils/audio_controller.dart';

class AudioSlider extends StatefulWidget {
  const AudioSlider(this.node, {Key? key}) : super(key: key);

  final Node node;

  @override
  State<AudioSlider> createState() => _AudioSliderState();
}

class _AudioSliderState extends State<AudioSlider> {
  bool drag = false;
  int value = 0;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    final play = context.watch<PlayScreenState>();
    if (!drag) value = audio.position;
    if (play.tr.audio(widget.node).isEmpty) return const SizedBox();
    if (audio.key != widget.node.id) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        constraints: const BoxConstraints(minHeight: 3),
      );
    }
    return slideUp(
      key: Key(audio.key),
      child: Slider(
        value: value.toDouble(),
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
