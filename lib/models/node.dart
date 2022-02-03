import 'package:andax/shared/utils.dart';
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
          json['id'] as String,
          actorId: json['actorId'] as String?,
          transitions: listFromJson(
            json['transitions'],
            (dynamic j) => Transition.fromJson(j as Map<String, dynamic>),
          ),
          autoTransition: json['autoTransition'] as bool? ?? false,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'actorId': actorId,
        'transitions': transitions?.map((c) => c.toJson()).toList(),
        'autoTransition': autoTransition,
      };
}
