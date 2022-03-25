import 'package:json_annotation/json_annotation.dart';

import 'actor.dart';

part 'translation.g.dart';

@JsonSerializable(explicitToJson: true)
class Translation {
  String language;
  final Map<String, String> assets;

  Translation({
    required this.language,
    Map<String, String> assets = const {},
  }) : assets = Map<String, String>.of(assets);

  String? operator [](String id) => assets[id];
  void operator []=(String id, String asset) => assets[id] = asset;

  String text(String id) => this[id] ?? '[MISSING TEXT]';
  String actor(Actor actor) => this[actor.id] ?? '[MISSING ACTOR]';

  String get title => this['title'] ?? '[MISSING TITLE]';
  set title(String v) => this['title'] = v;

  String get description => this['description'] ?? '[MISSING DESCRIPTION]';
  set description(String v) => this['description'] = v;

  String get tags => this['tags'] ?? '[MISSING TAGS]';
  set tags(String v) => this['tags'] = v;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this)..remove('assets');
}
