import 'package:andax/models/actor.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'actor_command.freezed.dart';
part 'actor_command.g.dart';

@freezed
class ActorCommand with _$ActorCommand {
  const factory ActorCommand.create(ActorType type) = _CreateActor;
  const factory ActorCommand.update(String id, {ActorType? type}) =
      _UpdateActor;
  const factory ActorCommand.delete(String id) = _DeleteActor;

  factory ActorCommand.fromJson(Map<String, dynamic> json) =>
      _$ActorCommandFromJson(json);
}
