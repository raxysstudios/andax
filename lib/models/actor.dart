import 'package:json_annotation/json_annotation.dart';

part 'actor.g.dart';

enum ActorType { npc, player }

@JsonSerializable()
class Actor {
  final String id;
  ActorType type;

  Actor({
    required this.id,
    this.type = ActorType.npc,
  });

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  Map<String, dynamic> toJson() => _$ActorToJson(this);
}
