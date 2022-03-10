import 'package:json_annotation/json_annotation.dart';

part 'transition.g.dart';

@JsonSerializable()
class Transition {
  final String id;
  String targetNodeId;

  Transition(
    this.id, {
    required this.targetNodeId,
  });

  factory Transition.fromJson(Map<String, dynamic> json) =>
      _$TransitionFromJson(json);

  Map<String, dynamic> toJson() => _$TransitionToJson(this);
}
