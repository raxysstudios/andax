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
    _position = 0;
    _url = url;
    _key = key ?? url;
    await player.stop();
    await player.play(url);
  }

  void stop() async {
    _url = '';
    await player.stop();
  }

  void toggle(String url, [String? key]) async {
    if (key == this.key) {
      if (playing) {
        pause();
      } else if (position == duration) {
        seek(0);
      } else {
        resume();
      }
    } else {
      play(url, key);
    }
  }

  void pause() => player.pause();
  void resume() => player.resume();

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
