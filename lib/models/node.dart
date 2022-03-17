import 'package:json_annotation/json_annotation.dart';

import 'transition.dart';

part 'node.g.dart';

enum EndingType { win, loss }
enum TransitionInputSource { random, select, cells }

@JsonSerializable(explicitToJson: true)
class Node {
  final String id;
  String? actorId;
  List<Transition>? transitions;
  Map<String, String>? cellWrites;
  TransitionInputSource transitionInputSource;

  Node(
    this.id, {
    this.actorId,
    this.transitions,
    this.cellWrites,
    this.transitionInputSource = TransitionInputSource.random,
  });

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}
