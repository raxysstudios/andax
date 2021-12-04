import 'package:enum_to_string/enum_to_string.dart';

enum ActorType {
  npc,
  player,
}

class Actor {
  String id;
  ActorType type;

  Actor({
    required this.id,
    this.type = ActorType.npc,
  });

  Actor.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String,
          type: EnumToString.fromString(
                ActorType.values,
                json['type'] as String? ?? '',
              ) ??
              ActorType.npc,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': EnumToString.convertToString(type),
      };
}
