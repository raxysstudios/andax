import 'package:andax/models/cell_check.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transition.g.dart';

@JsonSerializable()
class Transition {
  final String id;
  String targetNodeId;
  CellCheck condition;

  Transition(
    this.id, {
    required this.targetNodeId,
    required this.condition,
  });

  factory Transition.fromJson(Map<String, dynamic> json) =>
      _$TransitionFromJson(json);

  Map<String, dynamic> toJson() => _$TransitionToJson(this);
}
