import 'package:enum_to_string/enum_to_string.dart';
import 'package:andax/utils.dart';

import 'choice.dart';

enum EndingType { win, loss }

class Node {
  String id;
  String? actorId;
  EndingType? endingType;
  List<Choice>? choices;
  bool autoChoice;

  Node({
    required this.id,
    this.actorId,
    this.endingType,
    this.choices,
    this.autoChoice = false,
  });

  Node.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          actorId: json['actorId'],
          endingType: EnumToString.fromString(
            EndingType.values,
            json['endingType'],
          ),
          choices: listFromJson(
            json['choices'],
            (j) => Choice.fromJson(j),
          ),
          autoChoice: json['autoChoice'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorId': actorId,
        'endingType': endingType,
        'choices': choices?.map((c) => c.toJson()),
        'autoChoice': autoChoice,
      };
}
