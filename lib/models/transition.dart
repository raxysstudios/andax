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

enum ComparisionMode { equal, lesser, greater }

@JsonSerializable()
class CelledTransition extends Transition {
  String targetCellId;
  ComparisionMode? comparision;
  String value;

  CelledTransition(
    String id, {
    required String targetNodeId,
    this.targetCellId = '',
    this.comparision = ComparisionMode.equal,
    this.value = '',
  }) : super(id, targetNodeId: targetNodeId);

  factory CelledTransition.fromJson(Map<String, dynamic> json) =>
      _$CelledTransitionFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$CelledTransitionToJson(this));
}
