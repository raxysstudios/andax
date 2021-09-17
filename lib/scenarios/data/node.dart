import 'package:enum_to_string/enum_to_string.dart';
import 'package:andax/utils.dart';

enum EndingType { win, loss }

class Choice {
  String id;
  String targetNodeId;

  Choice({
    required this.id,
    required this.targetNodeId,
  });
}

class Node {
  String id;
  EndingType? endingType;
  List<Choice>? choices;

  Node({
    required this.id,
    this.endingType,
    this.choices,
  });

  Node.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          endingType: EnumToString.fromString(
            EndingType.values,
            json['endingType'],
          ),
          choices: listFromJson<Choice>(
            json['choices'],
            (j) => Choice(
              id: j['id'],
              targetNodeId: j['targetNoteId'],
            ),
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endingType': endingType,
      'choices': choices?.map(
        (c) => {
          'id': c.id,
          'targetNodeId': c.targetNodeId,
        },
      ),
    };
  }
}
