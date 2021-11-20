import 'package:andax/utils.dart';
import 'transition.dart';

enum EndingType { win, loss }

class Node {
  String id;
  String? actorId;
  List<Transition>? transitions;
  bool autoTransition;

  Node(
    this.id, {
    this.actorId,
    this.transitions,
    this.autoTransition = false,
  });

  Node.fromJson(Map<String, dynamic> json)
      : this(
          json['id'],
          actorId: json['actorId'],
          transitions: listFromJson(
            json['transitions'],
            (j) => Transition.fromJson(j),
          ),
          autoTransition: json['autoTransition'] ?? false,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorId': actorId,
        'transitions': transitions?.map((c) => c.toJson()).toList(),
        'autoTransition': autoTransition,
      };
}
