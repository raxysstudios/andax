import 'package:andax/models/cell.dart';
import 'package:json_annotation/json_annotation.dart';

import 'actor.dart';
import 'node.dart';
import 'transition.dart';

part 'translation.g.dart';

@JsonSerializable()
class Translation {
  String language;
  final Map<String, String> assets;
  static const missingTranslationLong = '_No translation available.'
      ' Please report the error to the authors of this story._';
  static const missingTranslationShort = '[Translation unavailable!]';

  Translation({
    this.language = '',
    Map<String, String> assets = const {},
  }) : assets = Map<String, String>.of(assets);

  String? operator [](String? id) => assets[id];
  void operator []=(String id, String asset) => assets[id] = asset;

  String node(Node? n) => this[n?.id] ?? missingTranslationLong;
  String transition(Transition? t) => this[t?.id] ?? missingTranslationShort;
  String actor(Actor? a) => this[a?.id] ?? missingTranslationShort;
  String cell(Cell? c) => this[c?.id] ?? missingTranslationShort;
  String audio(Node? n) => this['${n?.id}_audio'] ?? '';

  String get title => this['title'] ?? missingTranslationShort;
  String? get description => this['description'];
  String? get tags => this['tags'];

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this)..remove('assets');
}
