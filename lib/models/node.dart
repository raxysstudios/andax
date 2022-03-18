import 'package:andax/models/cell_write.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transition.dart';

part 'node.g.dart';

enum EndingType { win, loss }
enum TransitionInputSource { random, select, cells }

@JsonSerializable(explicitToJson: true)
class Node {
  final String id;
  String? actorId;
  List<Transition> transitions;
  List<CellWrite> cellWrites;
  TransitionInputSource transitionInputSource;

  Node(
    this.id, {
    this.actorId,
    List<Transition> transitions = const [],
    List<CellWrite> cellWrites = const [],
    this.transitionInputSource = TransitionInputSource.random,
  })  : transitions = transitions.toList(),
        cellWrites = cellWrites.toList();

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}
