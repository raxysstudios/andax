import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/audio_controller.dart';

class AudioSlider extends StatefulWidget {
  const AudioSlider(
    this.url, {
    this.playerKey,
    Key? key,
  }) : super(key: key);

  final String url;
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
    final current = audio.key == (widget.playerKey ?? widget.url);
    if (!drag) value = audio.position;
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            if (current) {
              if (audio.playing) {
                audio.pause();
              } else {
                audio.resume();
              }
            } else {
              audio.play(widget.url, widget.playerKey);
            }
          }),
          icon: Icon(
            current & audio.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
          ),
        ),
        Flexible(
          child: SliderTheme(
            data: const SliderThemeData(
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: 12,
              ),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
            ),
            child: Slider(
              value: value < audio.duration ? value.toDouble() : 0,
              max: audio.duration.toDouble(),
              onChanged: (s) => setState(() {
                drag = true;
                value = s.toInt();
              }),
              onChangeEnd: (s) async {
                await audio.seek(s.toInt());
                setState(() => drag = false);
              },
            ),
          ),
        ),
      ],
    );
  }
}
