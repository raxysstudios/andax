import 'package:enum_to_string/enum_to_string.dart';
import 'package:andax/utils.dart';

import 'transition.dart';

enum EndingType { win, loss }

class Node {
  String id;
  String? actorId;
  EndingType? endingType;
  List<Transition>? transitions;
  bool autoTransition;

  Node({
    required this.id,
    this.actorId,
    this.endingType,
    this.transitions,
    this.autoTransition = false,
  });

  Node.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          actorId: json['actorId'],
          endingType: json['endingType'] == null
              ? null
              : EnumToString.fromString(
                  EndingType.values,
                  json['endingType'],
                ),
          transitions: listFromJson(
            json['transitions'],
            (j) => Transition.fromJson(j),
          ),
          autoTransition: json['autoTransition'] ?? false,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorId': actorId,
        'endingType': endingType,
        'transitions': transitions?.map((c) => c.toJson()),
        'autoTransition': autoTransition,
      };
}
