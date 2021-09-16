import 'package:enum_to_string/enum_to_string.dart';
import 'package:andax/utils.dart';

enum EndingType { win, loss }

class Choice {
  String id;
  String note;
  String targetNodeId;

  Choice({
    required this.id,
    required this.note,
    required this.targetNodeId,
  });
}

class Node {
  String id;
  String note;
  EndingType? endingType;
  List<Choice>? choices;

  Node({
    required this.id,
    required this.note,
    this.endingType,
    this.choices,
  });

  Node.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          note: json['note'],
          endingType: EnumToString.fromString(
            EndingType.values,
            json['endingType'],
          ),
          choices: listFromJson<Choice>(
            json['choices'],
            (j) => Choice(
              id: j['id'],
              note: j['note'],
              targetNodeId: j['targetNoteId'],
            ),
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'endingType': endingType,
      'choices': choices?.map(
        (c) => {
          'id': c.id,
          'note': c.note,
          'targetNodeId': c.targetNodeId,
        },
      ),
    };
  }
}
