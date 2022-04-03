import 'package:andax/models/cell.dart';
import 'package:json_annotation/json_annotation.dart';

import 'actor.dart';
import 'node.dart';
import 'transition.dart';

part 'translation.g.dart';

@JsonSerializable(explicitToJson: true)
class Translation {
  String language;
  final Map<String, String> assets;

  Translation({
    this.language = '',
    Map<String, String> assets = const {},
  }) : assets = Map<String, String>.of(assets);

  String? operator [](String? id) => assets[id];
  void operator []=(String id, String asset) => assets[id] = asset;

  String node(Node? n, {bool allowEmpty = false}) =>
      this[n?.id] ?? (allowEmpty ? '' : '[❌NODE]');
  String transition(Transition? t) => this[t?.id] ?? '[❌TRANSITION]';
  String actor(Actor? a) => this[a?.id] ?? '[❌ACTOR]';
  String cell(Cell? c) => this[c?.id] ?? '[❌CELL]';

  String get title => this['title'] ?? '[❌TITLE]';
  String? get description => this['description'];
  String? get tags => this['tags'];

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this)..remove('assets');
}
