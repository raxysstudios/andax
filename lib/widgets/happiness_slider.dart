import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class HappinessSlider extends StatelessWidget {
  final int value;
  final int min, max;
  const HappinessSlider({
    Key? key,
    required this.value,
    this.min = 0,
    this.max = 100,
  }) : super(key: key);

  String get emoji {
    if (value <= 33) {
      return '☹️';
    }
    if (value >= 66) {
      return '😄';
    }
    return '😐';
  }

  Color get color {
    if (value <= 33) {
      // Sad
      return Colors.redAccent;
    }
    if (value >= 66) {
      // Happy
      return Colors.greenAccent;
    }
    // Neutral
    return Colors.yellowAccent;
  }

  @override
  Widget build(BuildContext context) {
    final size = 72.0;

    return FlutterSlider(
      min: 0,
      max: 100,
      values: [value.toDouble()],
      disabled: true,
      centeredOrigin: true,
      handlerHeight: size,
      handlerWidth: size,
      handler: FlutterSliderHandler(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.8),
        ),
        disabled: true,
      ),
      trackBar: FlutterSliderTrackBar(
        activeTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
        // inactiveDisabledTrackBarColor: color,
        activeDisabledTrackBarColor: color,
        // inactiveTrackBarHeight: 20,
        activeTrackBarHeight: 20,
      ),
    );
  }
}
