import 'package:andax/models/cell_write.dart';
import 'package:andax/models/image_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'transition.dart';

part 'node.g.dart';

enum EndingType { win, loss }

enum NodeInputType { random, select, none }

@JsonSerializable()
class Node {
  final String id;
  String? actorId;
  List<Transition> transitions;
  List<CellWrite> cellWrites;
  NodeInputType input;
  ImageData? image;

  Node(
    this.id, {
    this.actorId,
    List<Transition>? transitions,
    List<CellWrite>? cellWrites,
    this.image,
    this.input = NodeInputType.random,
  })  : transitions = transitions ?? [],
        cellWrites = cellWrites ?? [];

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}
