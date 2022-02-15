import 'package:json_annotation/json_annotation.dart';

part 'transition.g.dart';

@JsonSerializable()
class Transition {
  final String id;
  String targetNodeId;
  final int score;

  Transition(
    this.id, {
    required this.targetNodeId,
    this.score = 0,
  });

  factory Transition.fromJson(Map<String, dynamic> json) =>
      _$TransitionFromJson(json);

  Map<String, dynamic> toJson() => _$TransitionToJson(this)..remove('id');
}
