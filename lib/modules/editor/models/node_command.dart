import 'dart:io';

import 'package:andax/models/cell_write.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/transition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'node_command.freezed.dart';
part 'node_command.g.dart';

@freezed
class NodeCommand with _$NodeCommand {
  /// Required by `freezed` to be able to have common fields
  NodeCommand._();
  const factory NodeCommand.create({
    String? actorId,
    @Default(<Transition>[]) List<Transition> transitions,
    @Default(<CellWrite>[]) List<CellWrite> cellWrites,
    @JsonKey(ignore: true) File? image,
    @Default(NodeInputType.random) NodeInputType inputType,
  }) = _CreateNode;
  const factory NodeCommand.update(
    String id, {
    String? actorId,
    List<Transition>? transitions,
    List<CellWrite>? cellWrites,
    @JsonKey(ignore: true) File? image,
    NodeInputType? inputType,
  }) = _UpdateNode;
  const factory NodeCommand.delete(String id) = _DeleteNode;

  factory NodeCommand.fromJson(Map<String, dynamic> json) =>
      _$NodeCommandFromJson(json);

  UniqueKey? _key;

  /// The key is used to identify the node, so that when a new node is created
  ///  but needs to be referenced by another model, it can be identified.
  UniqueKey get key => _key ??= UniqueKey();
}
