import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController with ChangeNotifier {
  final player = AudioPlayer();

  AudioController() {
    player.onPlayerStateChanged.listen((s) {
      _playing = s == PlayerState.PLAYING;
      if (s == PlayerState.COMPLETED) {
        _position = _duration;
      }
      notifyListeners();
    });
    player.onDurationChanged.listen((d) {
      _duration = d.inMilliseconds;
      notifyListeners();
    });
    player.onAudioPositionChanged.listen((p) {
      _position = p.inMilliseconds;
      notifyListeners();
    });
  }

  void play(String url, [String? key]) async {
    await player.stop();
    _position = 0;
    _url = url;
    _key = key ?? url;
    player.play(url);
  }

  Future<void> seek(int mils) async {
    _position = mils;
    await player.seek(
      Duration(milliseconds: mils),
    );
    await player.resume();
  }

  String _url = '';
  String get url => _url;

  String _key = '';
  String get key => _key;

  var _playing = false;
  bool get playing => _playing;

  var _duration = 0;
  int get duration => _duration;

  var _position = 0;
  int get position => _position;
}
